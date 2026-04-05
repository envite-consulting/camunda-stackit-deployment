resource "random_password" "identity_connectors_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "identity_orchestration_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "identity_optimize_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "identity_console_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "initial_user_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_kv_secret_v2" "camunda_passwords" {
  mount = var.secret_store_path
  name  = local.camunda_passwords_secret

  data_json = jsonencode({
    firstUser             = random_password.initial_user_password.result
    identityConnectors    = random_password.identity_connectors_password.result
    identityOrchestration = random_password.identity_orchestration_password.result
    identityOptimize      = random_password.identity_optimize_password.result
    identityConsole       = random_password.identity_console_password.result
  })
}

resource "kubectl_manifest" "external_secret_camunda_passwords" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${local.camunda_passwords_secret}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.camunda_passwords_secret
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.camunda_passwords.name
          }
        },
      ]
    }
  })
}

resource "kubectl_manifest" "external_secret_opensearch_camunda" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${var.opensearch_credentials_kv_secret}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.opensearch_credentials_secret
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = var.opensearch_credentials_kv_secret
          }
        },
      ]
    }
  })
}

resource "kubectl_manifest" "external_secret_postgres_webmodeler" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${local.postgres_webmodeler_credentials_secret}"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.postgres_webmodeler_credentials_secret
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = var.webmodeler_postgres_credentials_kv_secret
          }
        },
      ]
    }
  })
}

resource "kubectl_manifest" "external_secret_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${local.keycloak_initial_admin_credentials_secret}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.keycloak_initial_admin_credentials_secret
        creationPolicy = "Owner"
      }
      dataFrom = [{ extract = { key = var.keycloak_initial_admin_password_kv_secret } }]
    }
  })
}
