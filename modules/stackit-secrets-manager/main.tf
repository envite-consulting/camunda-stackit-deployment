locals {
  secretsmanager_token_secret = "secretsmanager-token"
}

resource "stackit_secretsmanager_instance" "main" {
  project_id = var.project_id
  name       = var.name
}

resource "stackit_secretsmanager_user" "main" {
  project_id    = var.project_id
  instance_id   = stackit_secretsmanager_instance.main.instance_id
  description   = "Terraform automation user"
  write_enabled = true
}

resource "kubernetes_namespace_v1" "secret_store" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "vault_token" {
  metadata {
    name      = local.secretsmanager_token_secret
    namespace = kubernetes_namespace_v1.secret_store.metadata[0].name
  }

  data = {
    token = stackit_secretsmanager_user.main.password
  }

  type = "Opaque"
}


resource "kubectl_manifest" "secret_store_camunda" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = var.secret_store_path
    }
    spec = {
      provider = {
        vault = {
          server  = "https://prod.sm.eu01.stackit.cloud"
          path    = stackit_secretsmanager_user.main.instance_id
          version = "v2"

          auth = {
            userPass = {
              path     = "userpass"
              username = stackit_secretsmanager_user.main.username
              secretRef = {
                name      = kubernetes_secret_v1.vault_token.metadata[0].name
                key       = "token"
                namespace = kubernetes_namespace_v1.secret_store.metadata[0].name
              }
            }
          }
        }
      }
    }
  })
}
