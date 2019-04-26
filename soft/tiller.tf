/*
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: null
  generation: 1
  labels:
    app: helm
    name: tiller
  name: tiller-deploy
  selfLink: /apis/extensions/v1beta1/namespaces/kube-system/deployments/tiller-deploy
spec:
  progressDeadlineSeconds: 2147483647
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: helm
      name: tiller
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: helm
        name: tiller
    spec:
      automountServiceAccountToken: true
      containers:
      - env:
        - name: TILLER_NAMESPACE
          value: kube-system
        - name: TILLER_HISTORY_MAX
          value: "0"
        image: gcr.io/kubernetes-helm/tiller:v2.13.1
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /liveness
            port: 44135
            scheme: HTTP
          initialDelaySeconds: 1
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        name: tiller
        ports:
        - containerPort: 44134
          name: tiller
          protocol: TCP
        - containerPort: 44135
          name: http
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readiness
            port: 44135
            scheme: HTTP
          initialDelaySeconds: 1
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 1
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      serviceAccount: tiller
      serviceAccountName: tiller
      terminationGracePeriodSeconds: 30
*/

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
      labels {
        app  = "helm"
        name = "tiller"
      }
      "metadata" {}
      "spec" {
        automountServiceAccountToken = true
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
          image = "image: gcr.io/kubernetes-helm/tiller:v2.13.1"
          image_pull_policy = "IfNotPresent"
          liveness_probe {
            failure_threshold = 3
            http_get {
              path = "liveness"
              port = "44135"
              scheme = "http"
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
              scheme = "http"
            }
            initial_delay_seconds = 1
            period_seconds = 10
            success_threshold = 1
            timeout_seconds = 1
          }
        }
        service_account_name = "tiller"
        service_account = "tiller"
      }
    }
  }
}