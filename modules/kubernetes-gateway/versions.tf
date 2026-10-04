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
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0.0"
    }
  }
}

variable "cert_manager_chart_version" {
  description = "Helm chart version for cert-manager. See https://github.com/cert-manager/cert-manager/releases"
  type        = string
  default     = "v1.21.2"
}

variable "stackit_cert_manager_webhook_chart_version" {
  description = "Helm chart version for the STACKIT cert-manager DNS-01 webhook. See https://github.com/stackitcloud/stackit-cert-manager-webhook/releases"
  type        = string
  default     = "0.5.0"
}

variable "envoy_gateway_version" {
  description = "Envoy Gateway release, used for both the gateway-helm chart and the Envoy Gateway CRD bundle. See https://github.com/envoyproxy/gateway/releases"
  type        = string
  default     = "v1.9.2"
}

variable "gateway_api_version" {
  description = "Gateway API release whose standard-channel CRDs are installed. Must match envoy_gateway_version."
  type        = string
  default     = "v1.6.1"
}
