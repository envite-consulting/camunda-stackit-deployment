terraform {
  required_version = ">= 1.6.0"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.27.0"
    }
  }
}

variable "kubernetes_version_min" {
  description = "Minimum Kubernetes version for the SKE cluster. SKE auto-updates patch versions during maintenance windows. See SKE Dashboard for supported versions."
  type        = string
}
