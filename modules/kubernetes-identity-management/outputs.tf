output "keycloak_service_host" {
  description = "Internal service host for Keycloak"
  value       = "${var.service_name}.${var.namespace}.svc.cluster.local"
}

output "initial_admin_password_kv_secret" {
  description = "KV secret name for initial keycloak password"
  value       = vault_kv_secret_v2.keycloak_initial_admin_credentials.name
}
