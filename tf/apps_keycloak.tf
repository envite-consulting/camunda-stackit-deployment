data "http" "keycloak_crds" {
  url = var.keycloak_crds_url
}

data "http" "keycloak_crds_realmimports" {
  url = var.keycloak_crds_realmimports
}

data "http" "keycloak_operator" {
  url = var.keycloak_operator_url
}

data "kubectl_file_documents" "keycloak_operator_documents" {
  content = data.http.keycloak_operator.response_body
}

resource "kubectl_manifest" "keycloak_crds" {
  yaml_body = data.http.keycloak_crds.response_body
}

resource "kubectl_manifest" "keycloak_crds_realmimports" {
  yaml_body = data.http.keycloak_crds_realmimports.response_body
}

resource "kubectl_manifest" "keycloak_operator" {
  for_each = data.kubectl_file_documents.keycloak_operator_documents.manifests

  yaml_body          = each.value
  override_namespace = var.namespace_keycloak
  depends_on = [
    kubectl_manifest.keycloak_crds,
    kubectl_manifest.keycloak_crds_realmimports
  ]
}


locals {
  keycloak_ingress_manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "keycloak"
      namespace = var.namespace_keycloak
      annotations = {
        "kubernetes.io/ingress.class"    = "nginx"
        "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
      }
    }
    spec = {
      ingressClassName = "nginx"
      tls = [
        {
          hosts = [
            "keycloak.${var.dns_name}"
          ]
          secretName = var.secret_name_keycloak_tls
        }
      ]
      rules = [
        {
          host = "keycloak.${var.dns_name}"
          http = {
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = var.keycloak_service_name
                    port = {
                      number = 8080
                    }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}


locals {
  keycloak_manifest = {
    apiVersion = "k8s.keycloak.org/v2alpha1"
    kind       = "Keycloak"
    metadata = {
      name      = var.keycloak_name
      namespace = var.namespace_keycloak
    }
    spec = {
      instances = 1
      bootstrapAdmin = {
        user = {
          secret = var.secret_name_keycloak_initial_admin_password
        }
      }
      db = {
        vendor   = "postgres"
        host     = stackit_postgresflex_user.keycloak.host
        database = var.postgres_database_keycloak
        usernameSecret = {
          name = var.secret_name_postgres_keycloak
          key  = "username"
        }

        passwordSecret = {
          name = var.secret_name_postgres_keycloak
          key  = "password"
        }
      }

      http = {
        httpEnabled = true
      }

      ingress = {
        tlsSecret = var.secret_name_keycloak_tls
      }

      hostname = {
        hostname           = "https://keycloak.${var.dns_name}"
        backchannelDynamic = true
      }

      proxy = {
        headers = "xforwarded"
      }
    }
  }
}

resource "kubectl_manifest" "keycloak_ingress" {
  yaml_body = yamlencode(local.keycloak_ingress_manifest)

  depends_on = [
    kubernetes_namespace.keycloak,
    kubectl_manifest.keycloak_operator,
    helm_release.ingress_nginx,
    kubectl_manifest.clusterissuer_letsencrypt,
    helm_release.cert_manager,
    kubectl_manifest.external_secret_postgres_keycloak
  ]
}

resource "kubectl_manifest" "keycloak" {
  yaml_body = yamlencode(local.keycloak_manifest)

  depends_on = [

    stackit_postgresflex_database.keycloak,
    kubectl_manifest.keycloak_ingress,
    kubectl_manifest.external_secret_postgres_keycloak

  ]
}
