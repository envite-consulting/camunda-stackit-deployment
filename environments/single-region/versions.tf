terraform {
  required_version = "1.14.7"

  required_providers {
    stackit = {
      source = "stackitcloud/stackit"
      /*TODO: Workaround, because of local permission issues with Windows and version 0.87.0. Should be changed to ~> 0.87 */
      version = "~> 0.80.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.8"
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

variable "keycloak_operator_version" {
  description = "Keycloak Operator version to deploy. Controls all manifest URLs."
  type        = string
  default     = "26.5.5"
}

variable "camunda_helm_version" {
  description = "Camunda Helm version to deploy"
  type        = string
  default     = "13.5.3"
}

locals {
  keycloak_base_url = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/${var.keycloak_operator_version}/kubernetes"

  keycloak_operator_url      = "${local.keycloak_base_url}/kubernetes.yml"
  keycloak_crds_url          = "${local.keycloak_base_url}/keycloaks.k8s.keycloak.org-v1.yml"
  keycloak_crds_realmimports = "${local.keycloak_base_url}/keycloakrealmimports.k8s.keycloak.org-v1.yml"
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
  address          = "https://prod.sm.eu01.stackit.cloud"
  skip_child_token = true

  auth_login {
    path = "auth/userpass/login/${module.stackit_secrets_manager.user_username}"
    parameters = {
      password = module.stackit_secrets_manager.user_password
    }
  }
}
