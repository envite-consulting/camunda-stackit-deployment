locals {
  ingress_ngingx_values = {}
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.namespace_ingress_nginx
  version          = "4.12.1"
  create_namespace = true

  values = [
    yamlencode(local.ingress_ngingx_values)
  ]
}
