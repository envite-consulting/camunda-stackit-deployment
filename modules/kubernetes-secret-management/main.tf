resource "kubernetes_namespace_v1" "external_secrets" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.external_secrets_chart_version
  namespace  = kubernetes_namespace_v1.external_secrets.metadata[0].name
}

resource "kubernetes_secret_v1" "secrets_manager_password" {
  metadata {
    name      = "secretsmanager-password"
    namespace = kubernetes_namespace_v1.external_secrets.metadata[0].name
  }

  data = {
    password = var.secrets_manager_password
  }
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = var.secrets_manager.instance_id
    }
    spec = {
      provider = {
        vault = {
          server  = var.secrets_manager.vault_address
          path    = var.secrets_manager.instance_id
          version = "v2"
          auth = {
            userPass = {
              path     = "userpass"
              username = var.secrets_manager.username
              secretRef = {
                name      = kubernetes_secret_v1.secrets_manager_password.metadata[0].name
                namespace = kubernetes_secret_v1.secrets_manager_password.metadata[0].namespace
                key       = "password"
              }
            }
          }
        }
      }
    }
  })

  depends_on = [helm_release.external_secrets]
}
