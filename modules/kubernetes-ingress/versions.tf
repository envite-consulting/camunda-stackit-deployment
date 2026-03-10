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
  }
}

variable "ingress_nginx_chart_version" {
  description = "Helm chart version for ingress-nginx. Pin to a specific release. See https://github.com/kubernetes/ingress-nginx/releases"
  type        = string
  default     = "4.15.0"
}

variable "cert_manager_chart_version" {
  description = "Helm chart version for cert-manager. Pin to a specific release. See https://github.com/cert-manager/cert-manager/releases"
  type        = string
  default     = "v1.20.0"
}
