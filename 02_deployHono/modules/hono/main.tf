# https://github.com/bitnami/azure-marketplace-charts/tree/a2342181bacffa6d27d265db187dcc938af1c3f0/bitnami/mongodb
resource "helm_release" "mongodb" {
  name = "mongodb"

  repository      = "https://marketplace.azurecr.io/helm/v1/repo"
  chart           = "mongodb"
  version         = "~> 10.7.1"
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
  depends_on      = [helm_release.mongodb]
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