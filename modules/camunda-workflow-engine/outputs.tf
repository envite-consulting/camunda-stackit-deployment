output "namespace" {
  description = "Namespace of the Camunda components."
  value       = kubernetes_namespace_v1.camunda.metadata[0].name
}
