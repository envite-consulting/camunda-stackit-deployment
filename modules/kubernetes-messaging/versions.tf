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

variable "nats_chart_version" {
  description = "Helm chart version for NATS. Since chart 2.12, major.minor aligns with NATS Server version. See https://github.com/nats-io/k8s/releases"
  type        = string
  default     = "2.12.5"
}
