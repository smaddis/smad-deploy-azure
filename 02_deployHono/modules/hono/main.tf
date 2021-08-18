# https://github.com/eclipse/packages/tree/83abeda25c0efd9446713aaa828ff4177ce4b27b/charts/hono
resource "helm_release" "hono" {
  name = "hono"

  repository      = "https://eclipse.org/packages/charts"
  chart           = "hono"
  version         = "1.9.8"
  cleanup_on_fail = "true"
  #depends_on      = [helm_release.mongodb]
  values = [
    file("${path.module}/values.yaml")
  ]
  set {
    name  = "kafkaMessagingClusterExample.enabled"
    value = "true"
  }
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
# https://github.com/jetstack/cert-manager/tree/614438aed00e1060870b273f2238794ef69b60ab/deploy/charts/cert-manager
resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "~> 1.3.1"

  set {
    name  = "installCRDs"
    value = "true"
  }
}
