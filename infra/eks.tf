# --- We create the EKS cluster ---
resource "aws_eks_cluster" "eks" {
  name            = "${local.cluster_name}"
  role_arn        = "${aws_iam_role.eks-master.arn}"
  version         = "${var.master_eks_version}"

  vpc_config {
    security_group_ids = ["${aws_security_group.eks-master.id}"]
    subnet_ids         = ["${data.aws_subnet.first.id}", "${data.aws_subnet.second.id}", "${data.aws_subnet.third.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks-ClusterPolicy",
    "aws_iam_role_policy_attachment.eks-ServicePolicy",
  ]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.cluster_name} --verbose --alias ${local.cluster_name}"
  }
}

# --- We retrieve the lastest AMI to provision the EKS workers ---
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks.certificate_authority.0.data}' '${local.cluster_name}'
USERDATA
}

# --- We create the Worker autoscalling group ---
resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = false
  iam_instance_profile        = "${aws_iam_instance_profile.eks-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.worker_instance_type}"
  name_prefix                 = "${local.cluster_name}"
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {

  desired_capacity     = "${var.worker_desired_capacity}"
  launch_configuration = "${aws_launch_configuration.eks.id}"
  min_size             = "${var.worker_min_size}"
  max_size             = "${var.worker_max_size}"
  name                 = "${local.cluster_name}"
  vpc_zone_identifier  = ["${data.aws_subnet.first.id}", "${data.aws_subnet.second.id}"]

  tags = ["${( list(
      map("key", "Name",         "value", "${upper(format("%s_%s_%s", var.app_env, var.app_name,var.app_component ))}", "propagate_at_launch", true),
      map("key", "Env-Type",     "value", "${upper(var.envtype_tag)}", "propagate_at_launch", true),
      map("key", "Organization", "value", "${upper(var.organization_tag)}", "propagate_at_launch", true),
      map("key", "Application",  "value", "${upper(var.app_name)}", "propagate_at_launch", true),
      map("key", "Domaine",      "value", "${upper(var.domaine_tag)}", "propagate_at_launch", true),
      map("key", "Chapter",      "value", "${upper(var.chapter_tag)}", "propagate_at_launch", true),
      map("key", "kubernetes.io/cluster/${local.cluster_name}", "value", "owned", "propagate_at_launch", true)
       ))
  }"]
}