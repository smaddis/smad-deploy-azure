# https://github.com/bitnami/charts/tree/3f2b19ad2743d28828b5c217b2b682e0db57be75/bitnami/influxdb
resource "helm_release" "influx" {
  name       = "influx"
  repository = "https://helm.influxdata.com/"
  chart      = "influxdb"
  version    = "4.12.0"

  values = [
    file("${path.module}/values.yaml")
  ]

}