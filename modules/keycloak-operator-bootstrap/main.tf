data "http" "keycloak_crds" {
  url = var.keycloak_crds_url
}

data "http" "keycloak_crds_realmimports" {
  url = var.keycloak_crds_realmimports
}

data "http" "keycloak_operator" {
  url = var.keycloak_operator_url
}

data "kubectl_file_documents" "keycloak_operator_documents" {
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

resource "kubectl_manifest" "keycloak_crds_realmimports" {
  yaml_body = data.http.keycloak_crds_realmimports.response_body
}

resource "kubectl_manifest" "keycloak_operator" {
  for_each = data.kubectl_file_documents.keycloak_operator_documents.manifests

  yaml_body          = each.value
  override_namespace = kubernetes_namespace_v1.keycloak.metadata[0].name

  depends_on = [
    kubectl_manifest.keycloak_crds,
    kubectl_manifest.keycloak_crds_realmimports,
  ]
}
