terraform {
  required_version = ">= 1.6.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
  }
}

variable "keycloak_operator_version" {
  description = "Keycloak operator release; the operator deploys the Keycloak server of the same version."
  type        = string
  default     = "26.6.4"
}
