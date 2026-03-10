locals {
  host_name = "${var.hostname_prefix}.${var.dns_name}"

  initial_admin_credentials_secret = "keycloak-initial-admin-credentials"
  postgres_credentials_secret      = "postgres-credentials"
  ingress_tls_secret               = "keycloak-tls"

  keycloak_manifest = {
    apiVersion = "k8s.keycloak.org/v2alpha1"
    kind       = "Keycloak"
    metadata = {
      name      = var.name
      namespace = var.namespace
    }
    spec = {
      instances = 1
      bootstrapAdmin = {
        user = {
          secret = local.initial_admin_credentials_secret
        }
      }
      db = {
        vendor = "postgres"
        host   = var.postgres_host
        usernameSecret = {
          name = local.postgres_credentials_secret
          key  = "username"
        }
        passwordSecret = {
          name = local.postgres_credentials_secret
          key  = "password"
        }
      }

      http = {
        httpEnabled = true
      }

      ingress = {
        tlsSecret = local.ingress_tls_secret
      }

      hostname = {
        hostname           = "https://${local.host_name}"
        backchannelDynamic = true
      }

      proxy = {
        headers = "xforwarded"
      }
    }
  }
}

resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = "keycloak"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"    = "nginx"
      "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [local.host_name]
      secret_name = local.ingress_tls_secret
    }

    rule {
      host = local.host_name

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = var.service_name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

resource "kubectl_manifest" "keycloak" {
  yaml_body = yamlencode(local.keycloak_manifest)

  depends_on = [
    kubernetes_ingress_v1.keycloak_ingress
  ]
}


