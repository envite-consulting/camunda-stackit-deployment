locals {
  camunda_url    = "https://${var.hostname}"
  keycloak_realm = "camunda-platform"

  ingress_tls_secret    = "camunda-tls"
  zeebe_grpc_tls_secret = "camunda-zeebe-grpc-tls"

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
          "kubernetes.io/tls-acme"         = "true"
        }
        host = var.hostname
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
          username = var.opensearch.username
          secret = {
            existingSecret    = local.opensearch_credentials_secret
            existingSecretKey = "password"
          }
        }
        url = {
          protocol = "https"
          host     = var.opensearch.host
          port     = var.opensearch.port
        }
      }
      identity = {
        keycloak = {
          url = {
            protocol = "http"
            host     = var.keycloak.service_host
            port     = var.keycloak.service_port
          }
          contextPath = "/"
          realm       = "/realms/${local.keycloak_realm}"
          auth = {
            adminUser         = var.keycloak_initial_admin_user
            existingSecret    = local.keycloak_initial_admin_credentials_secret
            existingSecretKey = "password"
          }
        }
        auth = {
          enabled          = true
          type             = "KEYCLOAK"
          publicIssuerUrl  = "${var.keycloak.public_url}/realms/${local.keycloak_realm}"
          authUrl          = "${var.keycloak.public_url}/realms/${local.keycloak_realm}/protocol/openid-connect/auth"
          issuerBackendUrl = "http://${var.keycloak.service_host}:${var.keycloak.service_port}/realms/${local.keycloak_realm}"
          tokenUrl         = "http://${var.keycloak.service_host}:${var.keycloak.service_port}/realms/${local.keycloak_realm}/protocol/openid-connect/token"
          jwksUrl          = "http://${var.keycloak.service_host}:${var.keycloak.service_port}/realms/${local.keycloak_realm}/protocol/openid-connect/certs"
          admin = {
            secret = {
              existingSecret    = local.keycloak_initial_admin_credentials_secret
              existingSecretKey = "password"
            }
          }
          identity = {
            clientId    = "camunda-identity"
            redirectUrl = "${local.camunda_url}/managementidentity"
          }
          optimize = {
            secret = {
              existingSecret    = local.camunda_passwords_secret
              existingSecretKey = "identityOptimize"
            }
            redirectUrl = "${local.camunda_url}/optimize"
          }
          webModeler = {
            redirectUrl = "${local.camunda_url}/modeler"
          }
          console = {
            secret = {
              existingSecret    = local.camunda_passwords_secret
              existingSecretKey = "identityConsole"
            }
            redirectUrl = "${local.camunda_url}/console"
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
      fullURL     = "${local.camunda_url}/managementidentity"
      contextPath = "/managementidentity"
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
            redirectUrl = local.camunda_url
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
          host = var.zeebe_hostname
          tls = {
            enabled    = true
            secretName = local.zeebe_grpc_tls_secret
          }
        }
      }
      replicas          = var.zeebe_config.cluster_size
      clusterSize       = tostring(var.zeebe_config.cluster_size)
      partitionCount    = tostring(var.zeebe_config.partition_count)
      replicationFactor = tostring(var.zeebe_config.replication_factor)
      pvcSize           = var.zeebe_config.pvc_size
    }

    webModeler = {
      enabled     = true
      contextPath = "/modeler"
      restapi = {
        mail = {
          fromAddress = var.webmodeler_mail_from_address
        }
        externalDatabase = {
          enabled = true
          url     = "jdbc:postgresql://${var.webmodeler_postgres.host}:${var.webmodeler_postgres.port}/${var.webmodeler_postgres.database}"
          user    = var.webmodeler_postgres.username
          secret = {
            existingSecret    = local.postgres_webmodeler_credentials_secret
            existingSecretKey = "password"
          }
        }
      }
    }

    optimize = {
      enabled     = true
      contextPath = "/optimize"
    }

    console = {
      enabled     = true
      contextPath = "/console"
    }

    elasticsearch = {
      enabled = false
    }
  }
}
