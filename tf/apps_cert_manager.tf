locals {
  cert_manager_values = {
    crds = {
      enabled = true
    }
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = var.namespace_cert_manager
  version          = "v1.17.2"
  create_namespace = true

  values = [yamlencode(local.cert_manager_values)]

  depends_on = [
    helm_release.ingress_nginx
  ]
}

locals {
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
          name = var.secret_name_lets_encrypt_production
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

resource "kubectl_manifest" "clusterissuer_letsencrypt" {
  yaml_body = yamlencode(local.clusterissuer_letsencrypt_production)

  depends_on = [
    helm_release.cert_manager
  ]
}
