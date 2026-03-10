output "namespace" {
  value       = kubernetes_namespace_v1.keycloak.metadata[0].name
  description = "The namespace in which the Keycloak operator was deployed."
}
