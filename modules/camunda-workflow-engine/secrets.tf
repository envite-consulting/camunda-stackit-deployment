locals {
  camunda_passwords_secret                  = "camunda-passwords"
  opensearch_credentials_secret             = "opensearch-credentials"
  postgres_webmodeler_credentials_secret    = "postgres-webmodeler-credentials"
  keycloak_initial_admin_credentials_secret = "keycloak-initial-admin-credentials"
}

resource "random_password" "camunda" {
  for_each = toset(["firstUser", "identityConnectors", "identityOrchestration", "identityOptimize", "identityConsole"])

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "vault_kv_secret_v2" "camunda_passwords" {
  mount     = var.secret_store_path
  name      = local.camunda_passwords_secret
  data_json = jsonencode({ for key, password in random_password.camunda : key => password.result })
}

resource "kubectl_manifest" "external_secret" {
  for_each = {
    (local.camunda_passwords_secret)                  = vault_kv_secret_v2.camunda_passwords.name
    (local.opensearch_credentials_secret)             = var.opensearch.credentials_kv_secret
    (local.postgres_webmodeler_credentials_secret)    = var.webmodeler_postgres.credentials_kv_secret
    (local.keycloak_initial_admin_credentials_secret) = var.keycloak_initial_admin_password_kv_secret
  }

  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "es-${each.key}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
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
