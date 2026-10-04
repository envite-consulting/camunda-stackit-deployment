terraform {
  required_version = "1.16.3"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.117"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.3"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.12"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region = "eu01"

    use_lockfile = true

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}

locals {
  # Vault-compatible API of STACKIT Secrets Manager. Only the eu01 endpoint exists (prod.sm.eu02.stackit.cloud does
  # not resolve), so it does not follow var.stackit_region.
  secrets_manager_vault_address = "https://prod.sm.eu01.stackit.cloud"
}

provider "stackit" {
  default_region           = var.stackit_region
  service_account_key_path = var.sa_key_file_name
}

provider "helm" {
  kubernetes = {
    host                   = module.stackit_ske.kubeconfig.host
    client_certificate     = base64decode(module.stackit_ske.kubeconfig.client_certificate)
    client_key             = base64decode(module.stackit_ske.kubeconfig.client_key)
    cluster_ca_certificate = base64decode(module.stackit_ske.kubeconfig.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = module.stackit_ske.kubeconfig.host
  client_certificate     = base64decode(module.stackit_ske.kubeconfig.client_certificate)
  client_key             = base64decode(module.stackit_ske.kubeconfig.client_key)
  cluster_ca_certificate = base64decode(module.stackit_ske.kubeconfig.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = module.stackit_ske.kubeconfig.host
  client_certificate     = base64decode(module.stackit_ske.kubeconfig.client_certificate)
  client_key             = base64decode(module.stackit_ske.kubeconfig.client_key)
  cluster_ca_certificate = base64decode(module.stackit_ske.kubeconfig.cluster_ca_certificate)
  load_config_file       = false
}

provider "vault" {
  address          = local.secrets_manager_vault_address
  skip_child_token = true

  auth_login {
    path = "auth/userpass/login/${module.stackit_secrets_manager.user_username}"
    parameters = {
      password = module.stackit_secrets_manager.user_password
    }
  }
}
