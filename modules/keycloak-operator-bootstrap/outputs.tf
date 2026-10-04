output "namespace" {
  description = "Namespace of the Keycloak operator. Keycloak resources must be created here; they are ordered after the CRDs and the operator through this output."
  value       = kubernetes_namespace_v1.keycloak.metadata[0].name

  depends_on = [kubectl_manifest.keycloak_operator]
}
