#Practice based on: 
#https://github.com/hashicorp/terraform-provider-kubernetes/blob/master/_examples/aks/main.tf
#https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
#https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform

resource "kubernetes_namespace" "hono" {
  metadata {
    name = "hono"
  }
}

resource "helm_release" "mongodb" {
  name = "mongodb"

  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  chart      = "mongodb"
  version    = "~> 10.7.1"

  set {
    name  = "architecture"
    value = "standalone"
  }
  set {
    name  = "useStatefulSet"
    value = "true"
  }
  set_sensitive {
    name  = "auth.rootPassword"
    value = "root-secret"
  }
  set_sensitive {
    name  = "auth.password"
    value = "hono-secret"
  }  
  set_sensitive {
    name  = "auth.database"
    value = "honodb"
  }  
  set_sensitive {
    name  = "auth.username"
    value = "honouser"
  }  
  set {
    name  = "replicaCount"
    value = "2"
  }  
  set {
    name  = "cleanup_on_fail"
    value = "true"
  }
  # Uncomment these if you want the DB to be externally available. NB! Remember that this 
  # script also has auth credentials, so use external access with caution.
  # 
  # set {
  #   name  = "externalAccess.enabled"
  #   value = "true"
  # }
  # set {
  #   name  = "service.type"
  #   value = "LoadBalancer"
  # }
}

resource "helm_release" "hono" {
  name = "hono"

  repository = "https://eclipse.org/packages/charts"
  chart      = "hono"
  version    = "~> 1.5.9"
  depends_on = [helm_release.mongodb]

  set {
    name  = "prometheus.createInstance"
    value = "true"
  }
  set {
    name  = "jaegerBackendExample.enabled"
    value = "true"
  }
  set {
    name  = "grafana.enabled"
    value = "true"
  }
  set {
    name  = "mongodb.createInstance"
    value = "false"
  }
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "deviceRegistryExample.type"
    value = "mongodb"
  }
  set {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.host"
    value = "mongodb"
  }
  set {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.port"
    value = "27017"
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.dbName"
    value = "honodb"
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.username"
    value = "honouser"
  }
  set_sensitive {
    name  = "deviceRegistryExample.mongoDBBasedDeviceRegistry.mongodb.password"
    value = "hono-secret"
  }
  set {
    name  = "cleanup_on_fail"
    value = "true"
  }
}

/*
resource "kubernetes_deployment" "test" {
  metadata {
    name = "test"
    namespace= kubernetes_namespace.test.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "test"
      }
    }
    template {
      metadata {
        labels = {
          app  = "test"
        }
      }
      spec {
        container {
          image = "nginx:1.19.4"
          name  = "nginx"

          resources {
            limits = {
              memory = "512M"
              cpu = "1"
            }
            requests = {
              memory = "256M"
              cpu = "50m"
            }
          }
        }
      }
    }
  }
}
*/