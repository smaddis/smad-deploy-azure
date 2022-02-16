resource "helm_release" "kafka" {
  name = "kafka"

  repository      = "https://charts.bitnami.com/bitnami"
  chart           = "kafka"
  version         = "15.2.1"
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/values.yaml")
  ]
}
