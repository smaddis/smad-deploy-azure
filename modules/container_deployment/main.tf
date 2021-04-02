#Practice based on: 
#https://github.com/hashicorp/terraform-provider-kubernetes/blob/master/_examples/aks/main.tf
#https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
#https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform



# https://github.com/bitnami/azure-marketplace-charts/tree/master/bitnami/mongodb
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
    value = "root-secret"
  }
  set_sensitive {
    name  = "auth.password"
    value = "hono-secret"
  }
  set_sensitive {
    name  = "auth.username"
    value = "honouser"
  }

}

# https://github.com/eclipse/packages/tree/master/charts/hono
resource "helm_release" "hono" {
  name = "hono"

  repository      = "https://eclipse.org/packages/charts"
  chart           = "hono"
  version         = "~> 1.5.9"
  cleanup_on_fail = "true"
  depends_on      = [helm_release.mongodb]
  values = [
    file("${path.module}/hono_values.yaml")
  ]

  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.username"
    value = "honouser"
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.password"
    value = "hono-secret"
  }
}