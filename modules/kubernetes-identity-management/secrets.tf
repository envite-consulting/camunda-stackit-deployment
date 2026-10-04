locals {
  initial_admin_credentials_secret = "keycloak-initial-admin-credentials"
  postgres_credentials_secret      = "postgres-credentials"
}

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

resource "kubectl_manifest" "external_secret" {
  for_each = {
    (local.initial_admin_credentials_secret) = vault_kv_secret_v2.keycloak_initial_admin_credentials.name
    (local.postgres_credentials_secret)      = var.postgres_credentials_kv_secret
  }

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${each.key}"
      namespace = var.namespace
    }
    spec = {
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = var.cluster_secret_store_name
      }
      target = {
        name = each.key
      }
      dataFrom = [{ extract = { key = each.value } }]
    }
  })
}
