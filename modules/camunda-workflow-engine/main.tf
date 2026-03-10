locals {
  converted_opensearch_host = regexall("^(?:https?://)?([^:/]+)", var.opensearch_host)[0][0]

  opensearch_credentials_secret             = "opensearch-credentials"
  keycloak_initial_admin_credentials_secret = "keycloak-initial-admin-credentials"
  camunda_passwords_secret                  = "camunda-passwords"
  ingress_tls_secret                        = "camunda-tls"
  zeebe_grpc_tls_secret                     = "camunda-zeebe-grpc-tls"

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
          secretName = local.ingress_tls_secret
        }
      }
      elasticsearch = {
        enabled = false
      }
      opensearch = {
        enabled = true
        auth = {
          username = var.opensearch_username
          secret = {
            existingSecret    = local.opensearch_credentials_secret
            existingSecretKey = "password"
          }
        }
        url = {
          protocol = "https"
          host     = local.converted_opensearch_host
          port     = var.opensearch_port
        }
      }
      identity = {
        keycloak = {
          url = {
            protocol = "http"
            host     = var.keycloak_service_host
            port     = 8080
          }
          contextPath = "/"
          realm       = "/realms/${var.keycloak_realm}"
          auth = {
            adminUser         = var.keycloak_initial_admin_user
            existingSecret    = local.keycloak_initial_admin_credentials_secret
            existingSecretKey = "password"
          }
        }
        auth = {
          enabled         = true
          publicIssuerUrl = "https://keycloak.${var.dns_name}/realms/${var.keycloak_realm}"
          authUrl         = "https://keycloak.${var.dns_name}/realms/${var.keycloak_realm}/protocol/openid-connect/auth"

          issuerBackendUrl = "http://${var.keycloak_service_host}:8080/realms/${var.keycloak_realm}"
          tokenUrl         = "http://${var.keycloak_service_host}:8080/realms/${var.keycloak_realm}/protocol/openid-connect/token"
          jwksUrl          = "http://${var.keycloak_service_host}:8080/realms/${var.keycloak_realm}/protocol/openid-connect/certs"
          admin = {
            secret = {
              existingSecret    = local.keycloak_initial_admin_credentials_secret
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
          existingSecret    = local.camunda_passwords_secret
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
              existingSecret    = local.camunda_passwords_secret
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
              existingSecret    = local.camunda_passwords_secret
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
            secretName = local.zeebe_grpc_tls_secret
          }
        }
      }
      replicas          = var.zeebe_config.replicas
      clusterSize       = tostring(var.zeebe_config.replicas)
      partitionCount    = var.zeebe_config.partition_count
      replicationFactor = var.zeebe_config.replication_factor
      pvcSize           = var.zeebe_config.pvc_size_gb
    }

    optimize = {
      enabled = false
    }

    elasticsearch = {
      enabled = false
    }
  }
}

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

  values = [
    yamlencode(local.camunda_values)
  ]

  depends_on = [
    kubectl_manifest.external_secret_camunda_passwords,
  ]
}
