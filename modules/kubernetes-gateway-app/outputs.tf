output "gateway_name" {
  description = "Name of the Gateway. Taken from the applied resource, so that routes and policies are created after it."
  value       = kubectl_manifest.gateway.name
}
