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
    file("${path.module}/values.yaml")
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
