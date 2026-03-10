variable "project_id" {
  description = "STACKIT project ID under which the Secrets Manager instance is created."
  type        = string
}

variable "name" {
  description = "Name of the STACKIT Secrets Manager instance."
  type        = string
}

variable "secret_store_path" {
  description = "Name of the ESO ClusterSecretStore created for this Secrets Manager instance. Used by other modules to reference this store in ExternalSecret resources."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace in which the ESO ClusterSecretStore and related resources are deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}
