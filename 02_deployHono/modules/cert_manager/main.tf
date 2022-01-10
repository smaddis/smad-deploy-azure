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