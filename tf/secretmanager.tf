resource "stackit_secretsmanager_instance" "camunda" {
  project_id = var.project_id
  name       = "camunda-instance"
}

resource "stackit_secretsmanager_user" "terraform" {
  project_id    = var.project_id
  instance_id   = stackit_secretsmanager_instance.camunda.instance_id
  description   = "Terraform automation user"
  write_enabled = true
}

resource "kubernetes_secret" "vault_token_camunda" {
  metadata {
    name      = var.secret_name_vault_token
    namespace = var.namespace_camunda
  }

  data = {
    token = stackit_secretsmanager_user.terraform.password
  }

  type = "Opaque"
}

resource "kubectl_manifest" "secret_store_camunda" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name : var.secret_store_camunda
      namespace : var.namespace_camunda
    }
    spec = {
      provider = {
        vault = {
          server = var.vault_address
          path   = stackit_secretsmanager_instance.camunda.instance_id
          version : "v2"
          namespace : "secret" // TODO: Namespace prüfen

          auth = {
            userPass = {
              path : "userpass"
              username : stackit_secretsmanager_user.terraform.username
              secretRef = {
                name : var.secret_name_vault_token
                key : "token"
              }
            }
          }
        }
      }
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.external_secrets,
    kubernetes_namespace.camunda,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda,
  ]
}

resource "kubernetes_secret" "vault_token_keycloak" {
  metadata {
    name      = var.secret_name_vault_token
    namespace = var.namespace_keycloak
  }

  data = {
    token = stackit_secretsmanager_user.terraform.password
  }

  type = "Opaque"
}

resource "kubectl_manifest" "secret_store_keycloak" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "SecretStore"
    metadata = {
      name : var.secret_store_keycloak
      namespace : var.namespace_keycloak
    }
    spec = {
      provider = {
        vault = {
          server = var.vault_address
          path   = stackit_secretsmanager_instance.camunda.instance_id # Secrets-Manager-ID
          version : "v2"
          namespace : "secret" # Instance ID als Vault Namespace

          auth = {
            userPass = {
              path : "userpass"
              username : stackit_secretsmanager_user.terraform.username
              secretRef = {
                name : var.secret_name_vault_token
                key : "token"
              }
            }
          }
        }
      }
    }
  })

  depends_on = [
    helm_release.external_secrets,
    kubernetes_namespace.external_secrets,
    kubernetes_namespace.keycloak,
    kubernetes_secret.vault_token_camunda,
    stackit_secretsmanager_user.terraform,
    stackit_secretsmanager_instance.camunda
  ]
}
