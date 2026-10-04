resource "kubernetes_namespace_v1" "camunda" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "camunda" {
  name       = "camunda"
  repository = "https://helm.camunda.io"
  chart      = "camunda-platform"
  version    = var.camunda_platform_chart_version
  namespace  = kubernetes_namespace_v1.camunda.metadata[0].name

  values = [yamlencode(local.camunda_values)]

  depends_on = [kubectl_manifest.external_secret]
}
