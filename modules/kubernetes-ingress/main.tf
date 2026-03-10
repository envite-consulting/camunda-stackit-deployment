locals {
  cert_manager_values = {
    crds = {
      enabled = true
    }
  }

  clusterissuer_letsencrypt_production = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = var.cert_manager_cluster_issuer
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = var.cert_manager_cluster_issuer
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_namespace_v1" "ingress" {
  metadata {
    name = var.ingress_namespace
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_chart_version
  namespace  = kubernetes_namespace_v1.ingress.metadata[0].name
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = var.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name

  values = [yamlencode(local.cert_manager_values)]

  depends_on = [
    helm_release.ingress_nginx
  ]
}

resource "kubectl_manifest" "clusterissuer_letsencrypt" {
  yaml_body = yamlencode(local.clusterissuer_letsencrypt_production)

  depends_on = [
    helm_release.cert_manager
  ]
}
