# https://github.com/datawire/ambassador-chart/tree/c540b0d9e91f7def8a7d9b99217cb62cfe3014fb
resource "helm_release" "ambassador" {
  name = "ambassador"

  repository = "https://getambassador.io"
  chart      = "ambassador"
  version    = "~> 6.6.0"
  values = [
    file("${path.module}/values.yaml")
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