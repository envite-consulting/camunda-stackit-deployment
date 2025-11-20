#############################################
# STACKIT PostgreSQL Outputs (Camunda DB)
#############################################

output "postgres_dsn" {
  description = "PostgreSQL connection string for Camunda 8 components"
  value = format(
    "postgres://%s:%s@%s:%d/%s",
    stackit_postgresflex_user.camunda8_user.username,
    stackit_postgresflex_user.camunda8_user.password,
    stackit_postgresflex_user.camunda8_user.host,
    stackit_postgresflex_user.camunda8_user.port,
    stackit_postgresflex_database.camunda8_db.name
  )
  sensitive = true
}

output "postgres_host" {
  value       = stackit_postgresflex_user.camunda8_user.host
  description = "PostgreSQL host endpoint"
}

output "postgres_username" {
  value       = stackit_postgresflex_user.camunda8_user.username
  description = "PostgreSQL username"
}

output "postgres_password" {
  value       = stackit_postgresflex_user.camunda8_user.password
  description = "PostgreSQL password"
  sensitive   = true
}


#############################################
# STACKIT OpenSearch Outputs
#############################################

output "opensearch_endpoint" {
  description = "OpenSearch endpoint URL"
  value       = stackit_opensearch_credential.camunda8_credential.uri
  sensitive   = true
}

output "opensearch_username" {
  description = "OpenSearch username for Zeebe and Operate"
  value       = stackit_opensearch_credential.camunda8_credential.username
  sensitive   = true
}

output "opensearch_password" {
  description = "OpenSearch password for Zeebe and Operate"
  value       = stackit_opensearch_credential.camunda8_credential.password
  sensitive   = true
}


#############################################
# STACKIT Object Storage Outputs
#############################################

output "objectstorage_dsn" {
  description = "S3-compatible Object Storage connection string for Zeebe snapshots and backups"
  value = format(
    "s3://%s:%s@object.storage.eu01.onstackit.cloud/%s",
    stackit_objectstorage_credential.camunda8_credentials.access_key,
    stackit_objectstorage_credential.camunda8_credentials.secret_access_key,
    stackit_objectstorage_bucket.camunda8.name
  )
  sensitive = true
}

output "objectstorage_bucket" {
  description = "Name of the Object Storage bucket used for backups"
  value       = stackit_objectstorage_bucket.camunda8.name
}

output "objectstorage_access_key" {
  description = "Access key for S3-compatible Object Storage"
  value       = stackit_objectstorage_credential.camunda8_credentials.access_key
  sensitive   = true
}

output "objectstorage_secret_key" {
  description = "Secret key for S3-compatible Object Storage"
  value       = stackit_objectstorage_credential.camunda8_credentials.secret_access_key
  sensitive   = true
}
