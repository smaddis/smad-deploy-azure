# https://github.com/jaegertracing/helm-charts/tree/72db111cf61e9d85f75b74a8398f2c98da0bc9d3/charts/jaeger-operator
resource "helm_release" "jaeger-operator" {
  name = "jaeger-operator"

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  version    = "~> 2.19.1"
  values = [
    file("${path.module}/values.yaml")
  ]
}