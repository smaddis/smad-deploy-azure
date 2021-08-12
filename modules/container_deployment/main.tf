# Information used:
# https://github.com/hashicorp/terraform-provider-kubernetes/blob/0f97829b9df26a5d8f6719f750b6da71baa5454d/_examples/aks/main.tf
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
# https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform



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
  version         = "~> 1.9.4"
  cleanup_on_fail = "true"
  #depends_on      = [helm_release.mongodb]
  values = [
    file("${path.module}/hono_values.yaml")
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

# https://github.com/datawire/ambassador-chart/tree/c540b0d9e91f7def8a7d9b99217cb62cfe3014fb
resource "helm_release" "ambassador" {
  name = "ambassador"

  repository = "https://getambassador.io"
  chart      = "ambassador"
  version    = "~> 6.6.0"
  values = [
    file("${path.module}/ambassador_values.yaml")
  ]

  set {
    name  = "adminService.create"
    value = false
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-dns-label-name"
    value = var.k8s_dns_prefix
  }

}

# https://github.com/jaegertracing/helm-charts/tree/72db111cf61e9d85f75b74a8398f2c98da0bc9d3/charts/jaeger-operator
resource "helm_release" "jaeger-operator" {
  name = "jaeger-operator"

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  version    = "~> 2.19.1"
  values = [
    file("${path.module}/jaeger_values.yaml")
  ]

  /*
  set {
    name  = "jaeger.spec.ingress.hosts"
    value = "{${var.domain_name}}"
  }
  */
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

# Import Hono dashboards to Grafana. Basically copied from Hono Helm charts.
# How to import dashboards: https://github.com/grafana/helm-charts/tree/3327b6c7e9417f345774fd5a5eb46dd639ebeeec/charts/grafana#import-dashboards
# Sidecar method: https://github.com/grafana/helm-charts/tree/3327b6c7e9417f345774fd5a5eb46dd639ebeeec/charts/grafana#sidecar-for-dashboards
# This resource uses dashboard provisioning: https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards
# https://www.gitmemory.com/issue/helm/charts/16006/521211747
resource "kubernetes_secret" "grafana_hono_dashboards" {
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

# https://github.com/prometheus-community/helm-charts/tree/3ca6ba66032a1efce0500f9ad6f83351ad0604b8/charts/kube-prometheus-stack
# Values that can be set: `$ helm show values prometheus-community/kube-prometheus-stack` (repo has to be added first)
resource "helm_release" "kube-prometheus-stack" {
  name = "prometheus"

  repository      = "https://prometheus-community.github.io/helm-charts"
  chart           = "kube-prometheus-stack"
  version         = "~> 14.5.0"
  depends_on      = [kubernetes_secret.grafana_hono_dashboards]
  cleanup_on_fail = "true"
  values = [
    file("${path.module}/prom_values.yaml")
  ]

  set {
    name  = "grafana.ingress.hosts"
    value = "{${var.domain_name}}"
  }

  set {
    name  = "grafana.grafana\\.ini.server.domain"
    value = var.domain_name
  }
}
