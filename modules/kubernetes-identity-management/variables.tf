variable "namespace" {
  description = "Kubernetes namespace in which the Keycloak instance is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "name" {
  description = "Name of the Keycloak custom resource (Keycloak CR). Used as the base name for derived Kubernetes resources."
  type        = string
}

variable "initial_admin_name" {
  description = "Username of the initial Keycloak admin account bootstrapped on first startup."
  type        = string
}

variable "service_name" {
  description = "Name of the Kubernetes Service exposing the Keycloak backend. Referenced by the ingress and by other modules for cluster-internal communication."
  type        = string
}

variable "dns_name" {
  description = "Public base DNS name (e.g. 'example.com'). Combined with hostname_prefix to form the full Keycloak hostname."
  type        = string
}

variable "hostname_prefix" {
  description = "Subdomain prefix prepended to dns_name for the Keycloak ingress hostname (e.g. 'keycloak' → 'keycloak.example.com')."
  type        = string
}

variable "cert_manager_cluster_issuer" {
  description = "Name of the cert-manager ClusterIssuer used to provision the TLS certificate for the Keycloak ingress."
  type        = string
}

variable "secret_store_path" {
  description = "Name of the ESO ClusterSecretStore used to resolve ExternalSecret references within this module."
  type        = string
}

variable "postgres_credentials_kv_secret" {
  description = "Key in the ESO ClusterSecretStore that holds the PostgreSQL credentials (username + password) for the Keycloak database."
  type        = string
}

variable "postgres_host" {
  description = "Hostname or IP of the PostgreSQL instance used as the Keycloak database backend."
  type        = string
}
