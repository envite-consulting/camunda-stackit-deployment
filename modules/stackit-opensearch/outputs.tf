output "host" {
  description = "The host of the OpenSearch instance"
  value       = stackit_opensearch_credential.main.host
}

output "port" {
  description = "The port of the OpenSearch instance"
  value       = stackit_opensearch_credential.main.port
}

output "username" {
  description = "The username for OpenSearch"
  value       = stackit_opensearch_credential.main.username
}

output "credentials_kv_secret" {
  description = "Name of the KV secret for the OpenSearch credentials"
  value       = vault_kv_secret_v2.opensearch_camunda.name
}
