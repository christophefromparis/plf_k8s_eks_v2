variable "aws_vpc_name" {
  description = "The VPC name who hosted our EKS"
  default     = "VPC_VWIS-INFRA"
}

variable "aws_first_subnet_name" {
  description = "The name of the first private subnet"
  default     = "SB_VPC_VWIS-INFRA_PRI_A"
}

variable "aws_second_subnet_name" {
  description = "The name of the second private subnet"
  default     = "SB_VPC_VWIS-INFRA_PRI_B"
}

variable "aws_third_subnet_name" {
  description = "The name of the second private subnet"
  default     = "SB_VPC_VWIS-INFRA_PUB_A"
}

variable "aws_default_region" {
  description = "The default AWS region"
  default     = "eu-west-1"
}

variable "aws_route53_name" {
  description = "The Hosted Zone name"
  default     = "infra.istefr.fr"
}

variable "fqdn_prefix" {
  description = "The FQDN prefix"
  default     = "k"
}

# ------------------------
# --- The tags         ---
# ------------------------

variable "domaine_tag" {
  default = "PLATEFORME"
}

variable "chapter_tag" {
  default = "CLOUD-ACADEMY"
}

variable "envtype_tag" {
  default = "DEV"
}

variable "organization_tag" {
  default = "VWIS"
}

variable "app_name" {
  default = "K8S"
}

variable "app_env" {
  default = "DEV"
}

variable "app_component" {
  default = "EKS_INFRA"
}

# ------------------------
# --- The worker nodes ---
# ------------------------

variable "master_eks_version" {
  description = "The EKS version to install"
  default     = "1.12"
}

# ------------------------
# --- The worker nodes ---
# ------------------------

variable "worker_instance_type" {
  description = "The default instance type for the worker nodes"
  default     = "m4.large"
}

variable "worker_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  default     = 3
}

variable "worker_min_size" {
  description = "The minimum size of the auto scale group"
  default     = 3
}

variable "worker_max_size" {
  description = "The maximum size of the auto scale group"
  default     = 10
}

# ------------------------
# --- The labels ---
# ------------------------

variable "creator_label" {
  description = "The creators of the several artifact"
  default     = "Terraform_and_Christophe_Cosnefroy"
}