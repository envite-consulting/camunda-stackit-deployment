terraform {
  required_version = ">= 1.6.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

variable "external_secrets_chart_version" {
  description = "Helm chart version for external-secrets. ESO only supports the latest minor version — plan upgrades accordingly. See https://github.com/external-secrets/external-secrets/releases"
  type        = string
  default     = "1.3.2"
}
