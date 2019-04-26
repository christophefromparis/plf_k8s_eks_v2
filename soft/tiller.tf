resource "kubernetes_deployment" "tiller" {
  "metadata" {
    name      = "tiller-deploy"
    namespace = "kube-system"
    labels {
      app  = "helm"
      name = "tiller"
    }
  }
  "spec" {
    replicas = 1
    selector {
      match_labels {
        app = "helm"
        name = "tiller"
      }
    }
    "template" {
      "metadata" {
        labels {
          app  = "helm"
          name = "tiller"
        }
      }
      "spec" {
        //automountServiceAccountToken = true
        container {
          name = "tiller"
          env {
            name  = "TILLER_NAMESPACE"
            value = "kube-system"
          }
          env {
            name = "TILLER_HISTORY_MAX"
            value = 0
          }
          image = "gcr.io/kubernetes-helm/tiller:v2.13.1"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 3
            http_get {
              path = "liveness"
              port = "44135"
              scheme = "HTTP"
            }
            initial_delay_seconds = 1
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
          port {
            container_port = 44134
            name = "tiller"
            protocol = "TCP"
          }
          port {
            container_port = 44135
            name = "http"
            protocol = "TCP"
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path = "readiness"
              port = "44135"
              scheme = "HTTP"
            }
            initial_delay_seconds = 1
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
        }
        service_account_name = "tiller"
        //service_account = "tiller"
      }
    }
  }
}