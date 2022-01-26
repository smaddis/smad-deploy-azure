# https://github.com/bitnami/azure-marketplace-charts/tree/a2342181bacffa6d27d265db187dcc938af1c3f0/bitnami/mongodb
resource "helm_release" "mongodb" {
  name = "mongodb"

  repository      = "https://charts.bitnami.com/bitnami"
  chart           = "mongodb"
  version         = "10.31.3"
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/values.yaml")
  ]
}
