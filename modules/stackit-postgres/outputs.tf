output "db_host" {
  description = "The Postgres host"
  value       = stackit_postgresflex_user.main.host
}

output "db_port" {
  description = "The Postgres port"
  value = stackit_postgresflex_user.main.port
}

output "db_username" {
  description = "The Postgres username"
  value = stackit_postgresflex_user.main.username
}

output "postgres_credentials_kv_secret" {
  description = "The name of the Postgres credentials KV secret"
  value       = vault_kv_secret_v2.postgres_keycloak.name
}
