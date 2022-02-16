# https://github.com/bitnami/charts/tree/3f2b19ad2743d28828b5c217b2b682e0db57be75/bitnami/influxdb
resource "helm_release" "influx" {
  name       = "influx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "influxdb"
  version    = "1.1.8"

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "image.tag"
    value = "1.8.4"
  }

}