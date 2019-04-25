terraform {
  required_version = "~> 0.11.13"
  backend "s3" {}
}

# --- Providers ---
provider "aws" {
  version = "~> 2.2.0"
  region = "${var.aws_default_region}"
}

provider "template" {
  version = "~> 2.1"
}

# --- Data ---
data "aws_availability_zones" "available" {}

# --- Local variables ---
locals {
  cluster_name = "${upper(format("%s_%s_EKS_%s", var.domaine_tag, var.chapter_tag,var.envtype_tag ))}"

  common_tags = "${map(
    "Name"        , "${upper(format("%s_%s_%s", var.app_env, var.app_name,var.app_component ))}",
    "Env-Type"    , "${upper(var.envtype_tag)}",
    "Organization", "${upper(var.organization_tag)}",
    "Application" , "${upper(var.app_name)}",
    "Domaine"     , "${upper(var.domaine_tag)}",
    "Chapter"     , "${upper(var.chapter_tag)}",
    "kubernetes.io/cluster/${local.cluster_name}", "owned"
  )}"

  k8s_tags = "${map(
    "kubernetes.io/cluster/${local.cluster_name}", "owned"
  )}"
}

resource "aws_resourcegroups_group" "this" {
  name        = "Kubernetes"
  description = "The Cloud-Academy Kubernetes project"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance", "AWS::EC2::NetworkInterface", "AWS::EC2::SecurityGroup", "AWS::ECR::Repository", "AWS::ElasticLoadBalancing::LoadBalancer", "AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::ElasticLoadBalancingV2::TargetGroup", "AWS::SecretsManager::Secret", "AWS::S3::Bucket", "AWS::EC2::Volume", "AWS::EC2::Subnet", "AWS::EC2::VPC"
  ],
  "TagFilters": [
    {
      "Key": "kubernetes.io/cluster/${local.cluster_name}",
      "Values": []
    }
  ]
}
JSON
  }
}