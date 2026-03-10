variable "namespace" {
  description = "Kubernetes namespace in which the NATS messaging broker is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}
