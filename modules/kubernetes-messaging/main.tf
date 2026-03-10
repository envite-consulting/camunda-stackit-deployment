resource "kubernetes_namespace_v1" "nats" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "nats" {
  name       = "nats"
  repository = "https://nats-io.github.io/k8s/helm/charts/"
  chart      = "nats"
  version    = var.nats_chart_version
  namespace  = kubernetes_namespace_v1.nats.metadata[0].name
}
