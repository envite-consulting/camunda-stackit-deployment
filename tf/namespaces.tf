resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace_external_secrets
  }
}

resource "kubernetes_namespace" "camunda" {
  metadata {
    name = var.namespace_camunda
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = var.namespace_keycloak
  }
}
