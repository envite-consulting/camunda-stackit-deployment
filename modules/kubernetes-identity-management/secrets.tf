resource "random_password" "keycloak_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_kv_secret_v2" "keycloak_initial_admin_credentials" {
  mount = var.secret_store_path
  name  = local.initial_admin_credentials_secret

  data_json = jsonencode({
    username = var.initial_admin_name
    password = random_password.keycloak_admin_password.result
  })
}

resource "kubectl_manifest" "external_secret_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${local.initial_admin_credentials_secret}"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.initial_admin_credentials_secret
        creationPolicy = "Owner"
      }
      dataFrom = [{ extract = { key = vault_kv_secret_v2.keycloak_initial_admin_credentials.name } }]
    }
  })
}

resource "kubectl_manifest" "external_secret_postgres_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${local.postgres_credentials_secret}"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_path
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.postgres_credentials_secret
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = var.postgres_credentials_kv_secret
          }
        },
      ]
    }
  })
}
