locals {
  extracted_opensearch_host = regexall("^(?:https?://)?([^:/]+)", stackit_opensearch_credential.camunda.host)[0][0]
  keycloak_host = "${var.keycloak_service_name}.${var.namespace_keycloak}.svc.cluster.local"
  camunda_values = {
    global = {
      security = {
        authentication = {
          method = "oidc"
        }
      }
      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
        }
        host = var.dns_name
        tls = {
          enabled    = true
          secretName = var.secret_name_camunda_tls
        }
      }
      elasticsearch = {
        enabled = false
      }
      opensearch = {
        enabled = true
        auth = {
          username = stackit_opensearch_credential.camunda.username
          secret = {
            existingSecret    = var.secret_name_opensearch
            existingSecretKey = "password"
          }
        }
        url = {
          protocol = "https"
          host     = local.extracted_opensearch_host
          port     = stackit_opensearch_credential.camunda.port
        }
      }
      identity = {
        keycloak = {
          url = {
            protocol = "http"
            host     = local.keycloak_host
            port     = 8080
          }
          contextPath = "/"
          realm       = "/realms/${var.keycloak_realm}"
          auth = {
            adminUser         = var.keycloak_initial_admin.username
            existingSecret    = var.secret_name_keycloak_initial_admin_password
            existingSecretKey = "password"
          }
        }
        auth = {
          enabled         = true
          publicIssuerUrl = "https://keycloak.${var.dns_name}/realms/camunda-platform"
          authUrl         = "https://keycloak.${var.dns_name}/realms/camunda-platform/protocol/openid-connect/auth"

          issuerBackendUrl = "http://${local.keycloak_host}:8080/realms/camunda-platform"
          tokenUrl         = "http://${local.keycloak_host}:8080/realms/camunda-platform/protocol/openid-connect/token"
          jwksUrl          = "http://${local.keycloak_host}:8080/realms/camunda-platform/protocol/openid-connect/certs"
          admin = {
            secret = {
              existingSecret    = var.secret_name_keycloak_initial_admin_password
              existingSecretKey = "password"
            }
          }
          identity = {
            clientId = "camunda-identity"
          }
          optimize = {
            secret = {
              inlineSecret = "NOT_USED"
            }
          }
        }
      }
    }

    identity = {
      enabled = true
      firstUser = {
        enabled   = true
        username  = var.camunda_initial_user.username
        email     = var.camunda_initial_user.email
        firstName = var.camunda_initial_user.firstName
        lastName  = var.camunda_initial_user.lastName
        secret = {
          existingSecret    = var.secret_name_camunda_passwords
          existingSecretKey = "firstUser"
        }
      }
      fullURL     = "https://${var.dns_name}/managementidentity"
      contextPath = "/identity"
    }

    connectors = {
      contextPath = "/connectors"
      security = {
        authentication = {
          oidc = {
            secret = {
              existingSecret    = var.secret_name_camunda_passwords
              existingSecretKey = "identityConnectors"
            }
          }
        }
      }
    }

    orchestration = {
      contextPath = "/"
      security = {
        authentication = {
          oidc = {
            secret = {
              existingSecret    = var.secret_name_camunda_passwords
              existingSecretKey = "identityOrchestration"
            }
            redirectUrl = "https://${var.dns_name}"
          }
        }
        initialization = {
          defaultRoles = {
            admin = {
              users = [var.camunda_initial_user.username]
            }
          }
        }
      }
      ingress = {
        grpc = {
          enabled   = true
          className = "nginx"
          annotations = {
            "cert-manager.io/cluster-issuer" = var.cert_manager_cluster_issuer
          }
          host = "zeebe.${var.dns_name}"
          tls = {
            enabled    = true
            secretName = var.secret_name_zeebe_tls
          }
        }
      }
      replicas          = 1
      clusterSize       = "1"
      partitionCount    = "1"
      replicationFactor = "1"
      pvcSize           = "10Gi"
    }

    optimize = {
      enabled = false
    }

    elasticsearch = {
      enabled = false
    }
  }
}

resource "helm_release" "camunda" {
  name       = "camunda"
  repository = "https://helm.camunda.io"
  chart      = "camunda-platform"
  namespace  = var.namespace_camunda

  values = [
    yamlencode(local.camunda_values)
  ]

  depends_on = [
    kubernetes_namespace.camunda,
    kubectl_manifest.external_secret_camunda_passwords,
    stackit_opensearch_credential.camunda,
    kubectl_manifest.external_secret_opensearch_camunda,
    kubectl_manifest.external_secret_keycloak_2,
    kubectl_manifest.keycloak,
    helm_release.ingress_nginx,
    helm_release.cert_manager,
    kubectl_manifest.keycloak_operator,
    helm_release.nats,
    kubectl_manifest.clusterissuer_letsencrypt
  ]
}

