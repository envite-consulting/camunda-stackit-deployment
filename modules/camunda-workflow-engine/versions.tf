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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

variable "camunda_platform_chart_version" {
  description = "Helm chart version for camunda-platform. Chart 14.x deploys Camunda 8.9. See https://helm.camunda.io/camunda-platform/version-matrix/"
  type        = string
  default     = "14.11.0"
}
