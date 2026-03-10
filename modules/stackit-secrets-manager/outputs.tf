output "instance_id" {
  description = "The ID of the Secrets Manager instance"
  value       = stackit_secretsmanager_instance.main.instance_id
}

output "user_username" {
  description = "The username of the Secrets Manager user"
  value       = stackit_secretsmanager_user.main.username
}

output "user_password" {
  description = "The password of the Secrets Manager user"
  value       = stackit_secretsmanager_user.main.password
  sensitive   = true
}
