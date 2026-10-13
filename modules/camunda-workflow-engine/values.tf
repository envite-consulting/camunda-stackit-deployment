locals {
  camunda_url    = "https://${var.hostname}"
  keycloak_realm = "camunda-platform"
  hub_path       = "/hub"

  camunda_values = {
    global = {
      host = var.hostname
      security = {
        authentication = {
          method = "oidc"
        }
      }
      gateway = {
        enabled = true
        name    = var.gateway_name
        tls = {
          enabled = true
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
            adminUser = var.keycloak_initial_admin_user
            secret = {
              existingSecret    = local.keycloak_initial_admin_credentials_secret
              existingSecretKey = "password"
            }
          }
        }
        auth = {
          enabled         = true
          publicIssuerUrl = "${var.keycloak.public_url}/realms/${local.keycloak_realm}"
          optimize = {
            redirectUrl = "${local.camunda_url}/optimize"
            secret = {
              existingSecret    = local.camunda_passwords_secret
              existingSecretKey = "identityOptimize"
            }
          }
          camundaHub = {
            redirectUrl = "${local.camunda_url}${local.hub_path}"
          }
        }
      }
    }

    identity = {
      enabled     = true
      contextPath = "/managementidentity"
      firstUser = {
        username  = var.camunda_initial_user.username
        email     = var.camunda_initial_user.email
        firstName = var.camunda_initial_user.firstName
        lastName  = var.camunda_initial_user.lastName
        secret = {
          existingSecret    = local.camunda_passwords_secret
          existingSecretKey = "firstUser"
        }
      }
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
      env = [{
        name  = "CAMUNDA_CLIENT_AUTH_TOKENFETCHNONRETRYABLECOOLDOWN"
        value = "30s"
      }]
    }

    orchestration = {
      contextPath       = "/"
      clusterSize       = tostring(var.zeebe_config.cluster_size)
      partitionCount    = tostring(var.zeebe_config.partition_count)
      replicationFactor = tostring(var.zeebe_config.replication_factor)
      pvcSize           = var.zeebe_config.pvc_size
      gateway = {
        grpc = {
          enabled = true
          host    = var.zeebe_hostname
        }
      }
      data = {
        secondaryStorage = {
          type = "opensearch"
          opensearch = {
            url = "${var.opensearch.protocol}://${var.opensearch.host}:${var.opensearch.port}"
            auth = {
              username = var.opensearch.username
              secret = {
                existingSecret    = local.opensearch_credentials_secret
                existingSecretKey = "password"
              }
            }
          }
        }
      }
      security = {
        authentication = {
          oidc = {
            redirectUrl = local.camunda_url
            secret = {
              existingSecret    = local.camunda_passwords_secret
              existingSecretKey = "identityOrchestration"
            }
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
      extraConfiguration = [{
        file = "application-replicas.yaml"
        content = yamlencode({
          camunda = { data = { "secondary-storage" = { opensearch = { "number-of-replicas" = 0 } } } }
          zeebe   = { broker = { exporters = { opensearch = { args = { index = { numberOfReplicas = 0 } } } } } }
        })
      }]
    }

    camundaHub = {
      enabled     = true
      contextPath = local.hub_path
      restapi = {
        externalDatabase = {
          url      = "jdbc:postgresql://${var.hub_postgres.host}:${var.hub_postgres.port}/${var.hub_postgres.database}"
          username = var.hub_postgres.username
          secret = {
            existingSecret    = local.postgres_hub_credentials_secret
            existingSecretKey = "password"
          }
        }
        extraConfiguration = [{
          file = "application-mail.yaml"
          content = yamlencode({
            camunda = { hub = { mail = { "from-address" = var.hub_mail_from_address } } }
          })
        }]
      }
    }

    optimize = {
      enabled     = true
      contextPath = "/optimize"
      database = {
        opensearch = {
          enabled = true
          url = {
            protocol = var.opensearch.protocol
            host     = var.opensearch.host
            port     = var.opensearch.port
          }
          auth = {
            username = var.opensearch.username
            secret = {
              existingSecret    = local.opensearch_credentials_secret
              existingSecretKey = "password"
            }
          }
        }
      }
      extraConfiguration = [{
        file = "application-replicas.yaml"
        content = yamlencode({
          opensearch = { settings = { index = { number_of_replicas = 0 } } }
        })
      }]
    }
  }
}
