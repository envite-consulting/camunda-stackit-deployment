terraform {
  required_version = ">= 1.6.0"

  required_providers {
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
