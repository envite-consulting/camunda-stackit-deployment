variable "project_id" {
  description = "STACKIT project ID under which the Secrets Manager instance is created."
  type        = string
}

variable "name" {
  description = "Name of the STACKIT Secrets Manager instance."
  type        = string
}

variable "create_user_after" {
  description = "Values of the resources whose credentials are written to Secrets Manager. The user, and with it the login of the vault provider, is created only once they are known. Must not depend on anything written through the vault provider."
  type        = list(string)
  default     = []
}
