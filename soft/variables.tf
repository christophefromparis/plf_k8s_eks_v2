# --------------------------------
# ---- The Kubernetes cluster ----
# --------------------------------
variable "namespace_name" {
  description = "The default namespace name"
  type = "map"

  default = {
    global     = "global"
    monitoring = "monitoring"
    dev        = "dev"
    stage      = "stage"
    prod       = "prod"
  }
}
variable "tiller_version" {
  description = "The version of the Tiller docker image"
  default     = "v2.13.1"
}

# --------------------------------
# ------- The applications -------
# --------------------------------
variable "helm_version" {
  type = "map"

  default = {
    cert-manager  = "v0.6.7"
    external-dns  = "1.7.4"
    nginx-ingress = "1.6.0"
    prometheus    = "8.10.2"
    grafana       = "3.3.1"
    redis-ha      = "3.4.0"
    elasticsearch = "6.5.2-alpha1"
    kibana        = "6.5.2-alpha1"
    fluent-bit    = "1.9.2"
    fluentd       = "1.7.0"
    es-exporter   = "1.2.0"
    keycloak      = "4.10.0"
  }
}
variable "keycloak_username" {
  description = "The administrator username"
  default     = "yeltydevops"
}
variable "keycloak_password" {
  description = "The administrator password"
  default     = "changeme"
}
variable "fqdn_suffix" {
  description = "The FQDN suffix"
  default     = "k.infra.istefr.fr"
}
# --------------------------------
# ------------- AWS --------------
# --------------------------------
variable "aws_account" {
  description = "The AWS Yelty account"
  default     = "xxxxxxxxxxxx"
}