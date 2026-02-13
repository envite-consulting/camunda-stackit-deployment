provider "stackit" {
  default_region           = var.stackit_region
  service_account_key_path = var.sa_key_file_name
}

provider "kubernetes" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_certificate_authority
}

provider "kubectl" {
  host                   = local.kube_host
  client_certificate     = local.kube_client_certificate
  client_key             = local.kube_client_key
  cluster_ca_certificate = local.kube_certificate_authority
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_certificate_authority
  }
}

provider "vault" {
  address               = var.vault_address
  max_lease_ttl_seconds = 3600

  auth_login_userpass {
    username = stackit_secretsmanager_user.terraform.username
    password = stackit_secretsmanager_user.terraform.password
  }
}

provider "http" {}
