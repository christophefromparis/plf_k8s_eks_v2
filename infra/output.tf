output "aws_default_region" {
  value = "${var.aws_default_region}"
}
output "fqdn_suffix" {
  value = "${var.fqdn_prefix}.${var.aws_route53_name}"
}
output "k8s_endpoint" {
  value = "${aws_eks_cluster.eks.endpoint}"
}
output "eks_node_arn" {
  value = "${aws_iam_role.eks-node.arn}"
}
output "creator_label" {
  value = "${var.creator_label}"
}