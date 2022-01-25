# https://github.com/bitnami/charts/tree/ac496766e033c7d068094122164ef318c46fba15/bitnami/mongodb
resource "helm_release" "mongodb-devicereg" {
  name = "mongodb-devicereg"

  repository      = "https://charts.bitnami.com/bitnami"
  chart           = "mongodb"
  version         = "~> 10.31.3"
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/mongo_values.yaml")
  ]

  set_sensitive {
    name  = "auth.rootPassword"
    value = var.mongodb_rootPassword
  }
  set_sensitive {
    name  = "auth.password"
    value = var.mongodb_password
  }
  set_sensitive {
    name  = "auth.username"
    value = var.mongodb_username
  }

}
# https://github.com/eclipse/packages/tree/83abeda25c0efd9446713aaa828ff4177ce4b27b/charts/hono
resource "helm_release" "hono" {
  name = "hono"

  repository      = "https://eclipse.org/packages/charts"
  chart           = "hono"
  version         = "1.9.8"
  cleanup_on_fail = "true"
  depends_on      = [helm_release.mongodb-devicereg]
  values = [
    file("${path.module}/values.yaml")
  ]
  set {
    name  = "AmqpMessagingNetworkExample.enabled"
    value = "false"
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.username"
    value = var.mongodb_username
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.password"
    value = var.mongodb_password
  }
}