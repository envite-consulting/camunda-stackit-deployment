output "instance_id" {
  description = "ID of the Secrets Manager instance, which is also the mount path of its KV engine."
  value       = stackit_secretsmanager_instance.main.instance_id
}

output "user_username" {
  description = "Username of the Secrets Manager user (read and write)."
  value       = stackit_secretsmanager_user.main.username
}

output "user_password" {
  description = "Password of the Secrets Manager user."
  value       = stackit_secretsmanager_user.main.password
  sensitive   = true
}
