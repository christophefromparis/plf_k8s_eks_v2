terraform {
  required_version = "~> 0.11.13"
  backend "s3" {}
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config {
    region  = "eu-west-1"
    bucket  = "veolia-vwis-infra-irl-terraform"
    key     = "dev.k8s.infra.tfstate"
  }
}

provider "kubernetes" {
  version = "~> 1.5.2"
  host = "${data.terraform_remote_state.infra.k8s_endpoint}"
}

provider "helm" {
  version = "~> 0.9.0"
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.tiller_version}"
  service_account = "tiller"

  kubernetes {
    host     = "${data.terraform_remote_state.infra.k8s_endpoint}"

    client_certificate     = "${base64decode(data.terraform_remote_state.infra.client_certificate)}"
    client_key             = "${base64decode(data.terraform_remote_state.infra.client_key)}"
    cluster_ca_certificate = "${base64decode(data.terraform_remote_state.infra.cluster_ca_certificate)}"
  }
}

module "base" {
  source = "git::ssh://christophecosnefroyveolia@bitbucket.org/ist-efr/plf_k8s_base_module.git"

  gcp_credentials  = "${local.gcp_credentials}"
  dns_provider     = "google"
  gcp_project      = "${var.gcp_project}"
  cluster_provider = "google"
  helm_version     = ["${var.helm_version}"]
  namespace_name   = ["${var.namespace_name}"]
}

module "monitoring" {
  source = "git::ssh://christophecosnefroyveolia@bitbucket.org/ist-efr/plf_k8s_monitoring_module.git"

  fqdn_suffix            = "${var.fqdn_suffix}"
  cluster_provider       = "aws"
  redis_password         = "khs1d6f51d6sf16sdf1hljkj"
  grafana_admin_password = "changeme"
  helm_version           = ["${var.helm_version}"]
  monitoring_ns          = "${module.base.monitoring_ns}"
  stable_helm_repository = "${module.base.stable_helm_repository}"
}

module "keycloak" {
  source = "git::ssh://christophecosnefroyveolia@bitbucket.org/ist-efr/plf_k8s_keycloak_module.git"

  global_ns          = "${module.base.global_ns}"
  helm_version       = ["${var.helm_version}"]
  keycloak_username  = "${var.keycloak_username}"
  keycloak_password  = "${var.keycloak_password}"
  fqdn_suffix        = "${var.fqdn_suffix}"
}

module "nodejs" {
  source = "git::ssh://christophecosnefroyveolia@bitbucket.org/ist-efr/plf_k8s_nodejs_example_module.git"

  fqdn_suffix       = "${var.fqdn_suffix}"
  gcp_project       = "${var.gcp_project}"
  target_ns         = ["${module.base.developement_ns}", "${module.base.staging_ns}", "${module.base.production_ns}"]
  gcp_registry_host = "${var.gcp_registry_host}"
  developement_ns   = "${module.base.developement_ns}"
}