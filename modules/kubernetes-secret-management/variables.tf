variable "namespace" {
  description = "Kubernetes namespace in which the External Secrets Operator is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "secrets_manager" {
  description = "STACKIT Secrets Manager instance the ClusterSecretStore reads from."
  type = object({
    vault_address = string
    instance_id   = string
    username      = string
  })
}

variable "secrets_manager_password" {
  description = "Password of the Secrets Manager user."
  type        = string
  sensitive   = true
}
