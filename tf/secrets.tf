resource "vault_kv_secret_v2" "postgres_camunda" {
  mount = stackit_secretsmanager_instance.camunda.instance_id
  name  = "postgres-camunda"

  data_json = jsonencode({
    username = stackit_postgresflex_user.camunda.username
    password = stackit_postgresflex_user.camunda.password
    host     = stackit_postgresflex_user.camunda.host
    port     = stackit_postgresflex_user.camunda.port
    database = stackit_postgresflex_database.camunda.name
    jdbc_url = "jdbc:postgresql://${stackit_postgresflex_user.camunda.host}:${stackit_postgresflex_user.camunda.port}/${stackit_postgresflex_database.camunda.name}"
  })

  depends_on = [
    stackit_secretsmanager_instance.camunda,
    stackit_secretsmanager_user.terraform
  ]
}

resource "kubectl_manifest" "external_secret_postgres_camunda" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.postgres_camunda.name
      namespace = var.namespace_camunda
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_camunda
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_postgres_camunda
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.postgres_camunda.name
          }
        },
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.camunda,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}

resource "vault_kv_secret_v2" "postgres_keycloak" {
  mount = stackit_secretsmanager_instance.camunda.instance_id
  name  = "postgres-keycloak"

  data_json = jsonencode({
    username = stackit_postgresflex_user.keycloak.username
    password = stackit_postgresflex_user.keycloak.password
    host     = stackit_postgresflex_user.keycloak.host
    port     = stackit_postgresflex_user.keycloak.port
    database = stackit_postgresflex_database.keycloak.name
    jdbc_url = "jdbc:postgresql://${stackit_postgresflex_user.keycloak.host}:${stackit_postgresflex_user.keycloak.port}/${stackit_postgresflex_database.keycloak.name}"
  })

  depends_on = [
    stackit_secretsmanager_instance.camunda,
    stackit_secretsmanager_user.terraform
  ]
}

resource "kubectl_manifest" "external_secret_postgres_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.postgres_keycloak.name
      namespace = var.namespace_keycloak
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_keycloak
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_postgres_keycloak
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.postgres_keycloak.name
          }
        },
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.keycloak,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}

resource "vault_kv_secret_v2" "opensearch_camunda" {
  mount = stackit_secretsmanager_instance.camunda.instance_id
  name  = "opensearch-camunda"

  data_json = jsonencode({
    username = stackit_opensearch_credential.camunda.username
    password = stackit_opensearch_credential.camunda.password
    host     = stackit_opensearch_credential.camunda.host
    port     = stackit_opensearch_credential.camunda.port
    url      = "https://${stackit_opensearch_credential.camunda.host}:${stackit_opensearch_credential.camunda.port}"
  })

  depends_on = [
    stackit_secretsmanager_instance.camunda,
    stackit_secretsmanager_user.terraform
  ]
}

resource "kubectl_manifest" "external_secret_opensearch_camunda" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.opensearch_camunda.name
      namespace = var.namespace_camunda
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_camunda
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_opensearch
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.opensearch_camunda.name
          }
        },
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.camunda,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}

resource "vault_kv_secret_v2" "keycloak" {
  mount = stackit_secretsmanager_instance.camunda.instance_id
  name  = "keycloak-initial-admin"

  data_json = jsonencode({
    username = var.keycloak_initial_admin.username
    password = var.keycloak_initial_admin.password
  })

  depends_on = [
    stackit_secretsmanager_instance.camunda,
    stackit_secretsmanager_user.terraform
  ]
}

resource "kubectl_manifest" "external_secret_keycloak_ns_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.keycloak.name
      namespace = var.namespace_keycloak
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_keycloak
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_keycloak_initial_admin_password
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.keycloak.name
          }
        },
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.keycloak,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}

resource "kubectl_manifest" "external_secret_keycloak_2" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.keycloak.name
      namespace = var.namespace_camunda
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_camunda
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_keycloak_initial_admin_password
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = vault_kv_secret_v2.keycloak.name
          }
        },
      ]
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.camunda,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}

resource "vault_kv_secret_v2" "camunda_passwords" {
  mount = stackit_secretsmanager_instance.camunda.instance_id
  name  = "camunda"

  data_json = jsonencode({
    firstUser             = var.camunda_passwords.firstUser
    identityConnectors    = var.camunda_passwords.identityConnectors
    identityOrchestration = var.camunda_passwords.identityOrchestration
  })

  depends_on = [
    stackit_secretsmanager_instance.camunda,
    stackit_secretsmanager_user.terraform
  ]
}

resource "kubectl_manifest" "external_secret_camunda_passwords" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = vault_kv_secret_v2.camunda_passwords.name
      namespace = var.namespace_camunda
    }
    spec = {
      refreshInterval = "10s"
      secretStoreRef = {
        name = var.secret_store_camunda
        kind = "SecretStore"
      }
      target = {
        name           = var.secret_name_camunda_passwords
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

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.camunda,
    kubectl_manifest.secret_store_camunda,
    vault_kv_secret_v2.postgres_camunda,
    vault_kv_secret_v2.postgres_keycloak,
    vault_kv_secret_v2.camunda_passwords,
    vault_kv_secret_v2.opensearch_camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}
