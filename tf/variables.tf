# Projekt & DNS
variable "project_id" {
  description = "STACKIT project ID"
  type        = string
}

variable "stackit_region" {
  description = "Region for STACKIT Provider"
  type        = string
  default     = "eu01"
}

variable "sa_key_file_name" {
  description = "File Name for sa_key"
  type        = string
  default     = "sa_key.json"
}

variable "dns_name" {
  description = "DNS name for generated Zone (e.g. example.com.)"
  type        = string
}

# Postgres
variable "postgres_user_camunda" {
  description = "Postgres username for Camunda database"
  type        = string
  default     = "camunda_user"
}

variable "postgres_user_keycloak" {
  description = "Postgres username for Keycloak database"
  type        = string
  default     = "keycloak_user"
}
variable "postgres_database_camunda" {
  description = "Postgres database name for Camunda"
  type        = string
  default     = "camunda"
}
variable "postgres_database_keycloak" {
  description = "Postgres database name for Keycloak"
  type        = string
  default     = "keycloak"
}

variable "postgres_storage_class" {
  description = "Storage Class for Postgres volumes"
  type        = string
  default     = "premium-perf6-stackit"
}

# OpenSearch
variable "opensearch_plan" {
  description = "OpenSearch plan"
  type        = string
  default     = "stackit-opensearch-1.4.10-single"
}

# Camunda / Keycloak User & Secrets
variable "camunda_initial_user" {
  description = "Initial Camunda platform user"
  sensitive = true
  type = object({
    username  = string
    email     = string
    firstName = string
    lastName  = string
  })
}

variable "keycloak_initial_admin" {
  description = "Initial Keycloak admin user"
  sensitive = true
  type = object({
    username = string
    password = string
  })
}

variable "camunda_passwords" {
  description = "Passwords used by Camunda components"
  sensitive = true
  type = object({
    firstUser             = string
    identityConnectors    = string
    identityOrchestration = string
  })
}

# Kubernetes / SKE Cluster
variable "cluster_name" {
  description = "SKE cluster name"
  type        = string
  default     = "camunda"
}

variable "kubernetes_version_min" {
  description = "Minimum Kubernetes version for the cluster"
  type        = string
  default     = "1.34.3"
}

variable "ske_machine_type" {
  description = "Worker node machine type"
  type        = string
  default     = "g2i.16"
}

variable "ske_volume_type" {
  description = "Worker node volume type"
  type        = string
  default     = "storage_premium_perf2"
}

variable "ske_availability_zones" {
  description = "Availability zones for the cluster"
  type        = list(string)
  default     = ["eu01-1"]
}

variable "ske_maintenance_window" {
  description = "Maintenance window for the cluster"
  type = object({
    start = string
    end   = string
  })
  default = { start : "01:00:00Z", end : "02:00:00Z" }
}

# Namespaces
variable "namespace_camunda" {
  description = "Kubernetes namespace for Camunda"
  type        = string
  default     = "camunda"
}

variable "namespace_keycloak" {
  description = "Kubernetes namespace for Keycloak"
  type        = string
  default     = "keycloak"
}

variable "namespace_external_secrets" {
  description = "Kubernetes namespace for External Secrets Operator"
  type        = string
  default     = "external-secrets-system"
}

variable "namespace_ingress_nginx" {
  description = "Kubernetes namespace for ingress-nginx"
  type        = string
  default     = "ingress-nginx"
}

variable "namespace_cert_manager" {
  description = "Kubernetes namespace for cert manager"
  type        = string
  default     = "cert-manager"
}

variable "namespace_nats" {
  description = "Kubernetes namespace for nats"
  type        = string
  default     = "nats"
}

# Secrets & Secret Stores
variable "secret_name_camunda_tls" {
  description = "Name of TLS secret for Camunda ingress"
  type        = string
  default     = "camunda-tls"
}

variable "secret_name_keycloak_tls" {
  description = "Name of TLS secret for Keycloak ingress"
  type        = string
  default     = "keycloak-tls"
}

variable "secret_name_zeebe_tls" {
  description = "Name of TLS secret for Zeebe gRPC"
  type        = string
  default     = "camunda-zeebe-grpc-tls"
}

variable "secret_name_camunda_passwords" {
  description = "Name of secret containing Camunda component passwords"
  type        = string
  default     = "camunda-passwords"
}

variable "secret_name_keycloak_initial_admin_password" {
  description = "Name of secret containing Keycloak initial admin"
  type        = string
  default     = "keycloak-initial-admin-password"
}

variable "secret_name_postgres_camunda" {
  description = "Name of Postgres credentials secret for Camunda"
  type        = string
  default     = "postgres-camunda"
}

variable "secret_name_postgres_keycloak" {
  description = "Name of Postgres credentials secret for Keycloak"
  type        = string
  default     = "postgres-keycloak"
}

variable "secret_name_opensearch" {
  description = "Name of OpenSearch credentials secret"
  type        = string
  default     = "opensearch-camunda"
}

variable "secret_name_lets_encrypt_production" {
  description = "Name of secret for Let's Encrypt production certificates"
  type        = string
  default     = "letsencrypt-production"
}

variable "secret_name_vault_token" {
  description = "Name of secret for vault token"
  type        = string
  default     = "stackit-vault-token"
}

# Vault / Secrets Manager
variable "vault_address" {
  description = "Vault server address"
  type        = string
  default     = "https://prod.sm.eu01.stackit.cloud"
}

variable "secret_store_camunda" {
  description = "ExternalSecret store for Camunda"
  type        = string
  default     = "stackit-vault-camunda"
}

variable "secret_store_keycloak" {
  description = "ExternalSecret store for Keycloak"
  type        = string
  default     = "stackit-vault-keycloak"
}

# Keycloak / Operator
variable "keycloak_realm" {
  description = "Keycloak realm name"
  type        = string
  default     = "camunda-platform"
}

variable "keycloak_name" {
  description = "Keycloak resource name"
  type        = string
  default     = "camunda-keycloak"
}

variable "keycloak_service_name" {
  description = "Keycloak Kubernetes service name"
  type        = string
  default = "camunda-keycloak-service"
}

variable "keycloak_operator_url" {
  description = "URL to Keycloak operator manifest"
  type        = string
  default     = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/kubernetes.yml"
}

variable "keycloak_crds_url" {
  description = "URL to Keycloak CRDs"
  type        = string
  default     = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/keycloaks.k8s.keycloak.org-v1.yml"
}

variable "keycloak_crds_realmimports" {
  description = "URL to Keycloak realm import CRDs"
  type        = string
  default     = "https://raw.githubusercontent.com/keycloak/keycloak-k8s-resources/26.4.5/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml"
}

# Certificates
variable "cert_manager_cluster_issuer" {
  description = "cert-manager ClusterIssuer name"
  type        = string
  default     = "letsencrypt-production"
}