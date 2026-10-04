variable "namespace" {
  description = "Namespace of the Keycloak operator, in which the Keycloak instance is created."
  type        = string
}

variable "hostname" {
  description = "Public hostname of Keycloak (e.g. 'keycloak.camunda.example.com')."
  type        = string
}

variable "initial_admin_name" {
  description = "Username of the initial Keycloak admin account bootstrapped on first startup."
  type        = string
}

variable "secret_store_path" {
  description = "Mount path of the Secrets Manager KV engine (the Secrets Manager instance ID) to write secrets to."
  type        = string
}

variable "cluster_secret_store_name" {
  description = "Name of the ESO ClusterSecretStore that ExternalSecrets read from."
  type        = string
}

variable "postgres_credentials_kv_secret" {
  description = "Name of the KV secret holding the PostgreSQL credentials (username + password) for the Keycloak database."
  type        = string
}

variable "postgres_host" {
  description = "Hostname of the PostgreSQL instance used as the Keycloak database."
  type        = string
}

variable "postgres_database" {
  description = "Name of the PostgreSQL database used by Keycloak."
  type        = string
}

variable "gateway_name" {
  description = "Name of the Gateway (in this module's namespace) that the Keycloak HTTPRoute attaches to."
  type        = string
}

variable "gateway_listener_name" {
  description = "Name of the Gateway listener serving the Keycloak hostname. Used as sectionName of the HTTPRoute."
  type        = string
}
