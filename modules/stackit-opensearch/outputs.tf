locals {
  os = regex(
    "^(?P<protocol>[a-z]+)://(?:(?P<username>[^:@/]+):(?P<password>[^@/]+)@)?(?P<host>[^:/]+):(?P<port>[0-9]+)",
    stackit_opensearch_credential.main.host
  )
}

output "protocol" {
  description = "The protocol of the OpenSearch instance"
  value       = local.os["protocol"]
}

output "host" {
  description = "The host of the OpenSearch instance"
  value       = local.os["host"]
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
