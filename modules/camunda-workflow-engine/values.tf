locals {
  camunda_url    = "https://${var.hostname}"
  keycloak_realm = "camunda-platform"

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
          webModeler = {
            redirectUrl = "${local.camunda_url}/modeler"
          }
          console = {
            redirectUrl = "${local.camunda_url}/console"
            secret = {
              existingSecret    = local.camunda_passwords_secret
              existingSecretKey = "identityConsole"
            }
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
    }

    webModeler = {
      enabled     = true
      contextPath = "/modeler"
      restapi = {
        mail = {
          fromAddress = var.webmodeler_mail_from_address
        }
        externalDatabase = {
          url  = "jdbc:postgresql://${var.webmodeler_postgres.host}:${var.webmodeler_postgres.port}/${var.webmodeler_postgres.database}"
          user = var.webmodeler_postgres.username
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
    }

    console = {
      enabled     = true
      contextPath = "/console"
    }
  }
}
