locals {
  public_url = "https://${var.hostname}"

  service_name       = "${kubectl_manifest.keycloak.name}-service"
  http_port          = 8080
  ingress_tls_secret = "keycloak-tls"
}

resource "kubectl_manifest" "keycloak" {
  yaml_body = yamlencode({
    apiVersion = "k8s.keycloak.org/v2beta1"
    kind       = "Keycloak"
    metadata = {
      name      = "camunda-keycloak"
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
        hostname           = local.public_url
        backchannelDynamic = true
      }

      proxy = {
        headers = "xforwarded"
      }
    }
  })
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
      hosts       = [var.hostname]
      secret_name = local.ingress_tls_secret
    }

    rule {
      host = var.hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = local.service_name
              port {
                number = local.http_port
              }
            }
          }
        }
      }
    }
  }
}
