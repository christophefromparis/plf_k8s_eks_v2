
# --- We retrieve the VPC ---
data "aws_vpc" "vwis-dev" {
  filter {
    name = "tag:Name"
    values = ["${var.aws_vpc_name}"]
  }
}

# --- We retrieve the subnets ---
data "aws_subnet" "first" {
  filter {
    name = "tag:Name"
    values = ["${var.aws_first_subnet_name}"]
  }
}

data "aws_subnet" "second" {
  filter {
    name = "tag:Name"
    values = ["${var.aws_second_subnet_name}"]
  }
}

data "aws_subnet" "third" {
  filter {
    name = "tag:Name"
    values = ["${var.aws_third_subnet_name}"]
  }
}

# --- We retrieve the Internet Gateway ---
data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = ["${data.aws_vpc.vwis-dev.id}"]
  }
}

# --- We create the subnet routing to route external traffic through the internet gateway ---
resource "aws_route_table" "eks-to-internet" {
  vpc_id = "${data.aws_vpc.vwis-dev.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${data.aws_internet_gateway.default.id}"
  }
}

# --- We retrieve the Route53 zone ---
data "aws_route53_zone" "infra-istefr-fr" {
  name         = "${var.aws_route53_name}"
}

# --- We create the sub domain ---
resource "aws_route53_zone" "k8s" {
  name = "${var.fqdn_prefix}.${var.aws_route53_name}"


  tags = "${local.common_tags}"
}

resource "aws_route53_record" "k8s-infra-istefr-fr" {
  zone_id = "${data.aws_route53_zone.infra-istefr-fr.zone_id}"
  name    = "${aws_route53_zone.k8s.name}"
  type    = "NS"
  ttl     = "60"
  records = ["${aws_route53_zone.k8s.name_servers}"]
}
