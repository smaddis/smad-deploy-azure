#Practice based on: 
#https://github.com/hashicorp/terraform-provider-kubernetes/blob/master/_examples/aks/main.tf
#https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
#https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform

resource "kubernetes_namespace" "hono" {
  metadata {
    name = "hono"
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
resource "helm_release" "hono" {
  name       = "hono"

  repository = "https://eclipse.org/packages/charts"
  chart      = "hono"

  set {
    name  = "jaegerBackendExample.enabled prometheus.createInstance grafana.enabled"
    value = "true"
  }
  set {
    name = "mongodb.createInstance"
    value = "true"
  }
  set {
    name = "grafana.service.type"
    value = "LoadBalancer"
  }
}

