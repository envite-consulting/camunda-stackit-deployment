output "public_url" {
  description = "Public Keycloak URL, as seen by browsers and used as issuer in tokens."
  value       = local.public_url
}

output "service_host" {
  description = "Cluster-internal host name of the Keycloak Service."
  value       = "${local.service_name}.${var.namespace}.svc.cluster.local"
}

output "service_port" {
  description = "HTTP port of the Keycloak Service."
  value       = local.http_port
}

output "initial_admin_password_kv_secret" {
  description = "Name of the KV secret holding the initial Keycloak admin credentials."
  value       = vault_kv_secret_v2.keycloak_initial_admin_credentials.name
}
