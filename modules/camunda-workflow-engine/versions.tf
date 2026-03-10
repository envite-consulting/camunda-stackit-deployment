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
      version = "~> 1.14"
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
  description = "Helm chart version for camunda-platform. Since Camunda 8.4, chart version is decoupled from app version (e.g. chart 13.x = app 8.7.x). See version matrix: https://helm.camunda.io/camunda-platform/version-matrix/"
  type        = string
}
