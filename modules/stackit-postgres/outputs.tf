output "db_host" {
  description = "The Postgres host"
  value       = stackit_postgresflex_user.main.host
}

output "db_port" {
  description = "The Postgres port"
  value       = stackit_postgresflex_user.main.port
}

output "db_username" {
  description = "The Postgres username"
  value       = stackit_postgresflex_user.main.username
}

output "database_names" {
  description = "Names of the created databases"
  value       = [for db in stackit_postgresflex_database.main : db.name]
}

output "postgres_credentials_kv_secret" {
  description = "Name of the KV secret holding the Postgres credentials (username + password)"
  value       = vault_kv_secret_v2.credentials.name
}
