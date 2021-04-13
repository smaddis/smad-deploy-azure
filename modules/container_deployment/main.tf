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
  depends_on      = [helm_release.kube-prometheus-stack]
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

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
}

resource "helm_release" "jaeger-operator" {
  name = "jaeger-operator"

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  values = [
    file("${path.module}/jaeger_values.yaml")
  ]
}

# Import Hono dashboards to Grafana. Basically copied from Hono Helm charts.
# How to import dashboards: https://github.com/grafana/helm-charts/tree/main/charts/grafana#import-dashboards
# This resource uses sidecar method: https://github.com/grafana/helm-charts/tree/main/charts/grafana#sidecar-for-dashboards.
resource "kubernetes_config_map" "grafana_hono_dashboards" {
  metadata {
    name = "grafana-hono-dashboards"
    labels = {
      "grafana_dashboard" : "1" # Add labels so that Grafana finds these
    }
  }

  data = {
    "jvm-details.json"     = file("${path.module}/Grafana_Dashboards/JVM_details_grafana_ds.json")
    "message-details.json" = file("${path.module}/Grafana_Dashboards/Message_details_grafana_ds.json")
    "overview.json"        = file("${path.module}/Grafana_Dashboards/Overview_grafana_ds.json")
  }
}

# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
# Values that can be set: `$ helm show values prometheus-community/kube-prometheus-stack` (repo has to be added first)
resource "helm_release" "kube-prometheus-stack" {
  name = "prometheus"

  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "kube-prometheus-stack"
  version         = "~> 14.5.0"
  depends_on      = [helm_release.mongodb, kubernetes_config_map.grafana_hono_dashboards]
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/prom_values.yaml")
  ]
}