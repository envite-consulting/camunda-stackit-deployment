locals {
  manifests_base_url = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${var.keycloak_operator_version}/kubernetes"
}

data "http" "keycloak_crds" {
  url = "${local.manifests_base_url}/keycloaks.k8s.keycloak.org-v1.yml"
}

data "http" "keycloak_realmimports_crds" {
  url = "${local.manifests_base_url}/keycloakrealmimports.k8s.keycloak.org-v1.yml"
}

data "http" "keycloak_operator" {
  url = "${local.manifests_base_url}/kubernetes.yml"
}

data "kubectl_file_documents" "keycloak_operator" {
  content = data.http.keycloak_operator.response_body
}

resource "kubernetes_namespace_v1" "keycloak" {
  metadata {
    name = var.namespace
  }
}

resource "kubectl_manifest" "keycloak_crds" {
  yaml_body = data.http.keycloak_crds.response_body
}

resource "kubectl_manifest" "keycloak_realmimports_crds" {
  yaml_body = data.http.keycloak_realmimports_crds.response_body
}

resource "kubectl_manifest" "keycloak_operator" {
  for_each = data.kubectl_file_documents.keycloak_operator.manifests

  yaml_body          = each.value
  override_namespace = kubernetes_namespace_v1.keycloak.metadata[0].name

  depends_on = [
    kubectl_manifest.keycloak_crds,
    kubectl_manifest.keycloak_realmimports_crds,
  ]
}
