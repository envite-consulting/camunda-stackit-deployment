variable "namespace" {
  description = "Kubernetes namespace in which all Camunda components are deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "dns_name" {
  description = "Public base DNS name for Camunda ingress (e.g. 'camunda.example.com'). Used to construct component-specific hostnames."
  type        = string
}

variable "cert_manager_cluster_issuer" {
  description = "Name of the cert-manager ClusterIssuer used to provision TLS certificates for Camunda ingress resources."
  type        = string
}

variable "secret_store_path" {
  description = "Name of the ESO ClusterSecretStore used to resolve ExternalSecret references within this module."
  type        = string
}

variable "opensearch_credentials_kv_secret" {
  description = "Key in the ESO ClusterSecretStore that holds the OpenSearch credentials (username + password)."
  type        = string
}

variable "keycloak_initial_admin_password_kv_secret" {
  description = "Key in the ESO ClusterSecretStore that holds the Keycloak initial admin password."
  type        = string
}

variable "opensearch_host" {
  description = "Hostname or IP of the OpenSearch cluster used by Camunda Operate and Tasklist."
  type        = string
}

variable "opensearch_port" {
  description = "Port on which the OpenSearch cluster is reachable."
  type        = number

  validation {
    condition     = var.opensearch_port > 0 && var.opensearch_port <= 65535
    error_message = "opensearch_port must be a valid port number between 1 and 65535."
  }
}

variable "opensearch_username" {
  description = "Username for authenticating against OpenSearch. The corresponding password is resolved via opensearch_credentials_kv_secret."
  type        = string
}

variable "keycloak_service_host" {
  description = "Internal Kubernetes service hostname for Keycloak (e.g. 'keycloak.keycloak.svc.cluster.local'). Used for cluster-internal OIDC communication."
  type        = string
}

variable "keycloak_realm" {
  description = "Keycloak realm used for Camunda OIDC authentication."
  type        = string
}

variable "keycloak_initial_admin_user" {
  description = "Username of the initial Keycloak admin account. Used to bootstrap Camunda realm and client configuration."
  type        = string
}

variable "camunda_initial_user" {
  description = "Initial Camunda platform user created on first startup. Used to seed the first human task operator account."
  type = object({
    username  = string
    email     = string
    firstName = string
    lastName  = string
  })
}

variable "zeebe_config" {
  description = <<-EOT
    Zeebe broker cluster sizing configuration.
    - replicas:           Number of broker pods. Must equal replication_factor for a fully balanced cluster.
    - replication_factor: Number of copies per partition. Should match replicas in production.
    - partition_count:    Number of partitions. Should be >= replicas for even distribution.
    - pvc_size_gb:        Size of the persistent volume per broker (e.g. '10Gi', '50Gi').
  EOT
  type = object({
    replicas           = number
    replication_factor = string
    partition_count    = string
    pvc_size_gb        = string
  })

  validation {
    condition     = tonumber(var.zeebe_config.partition_count) >= var.zeebe_config.replicas
    error_message = "partition_count must be >= replicas for optimal partition distribution across brokers."
  }

  validation {
    condition     = tonumber(var.zeebe_config.replication_factor) <= var.zeebe_config.replicas
    error_message = "replication_factor cannot exceed the number of replicas (brokers)."
  }

  validation {
    condition     = can(regex("^[0-9]+(Gi|Mi)$", var.zeebe_config.pvc_size_gb))
    error_message = "pvc_size_gb must be a valid Kubernetes quantity, e.g. '10Gi' or '512Mi'."
  }
}
