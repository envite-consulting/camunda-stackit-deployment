output "db_host" {
  description = "The Postgres host"
  value       = stackit_postgresflex_user.main.host
}

output "postgres_credentials_kv_secret" {
  description = "The name of the Postgres credentials KV secret"
  value       = vault_kv_secret_v2.postgres_keycloak.name
}
