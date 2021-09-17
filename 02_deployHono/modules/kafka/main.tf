resource "helm_release" "kafka" {
  name = "kafka"

  repository      = "https://charts.bitnami.com/bitnami"
  chart           = "kafka"
  version         = "14.0.5"
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/values.yaml")
  ]
}
