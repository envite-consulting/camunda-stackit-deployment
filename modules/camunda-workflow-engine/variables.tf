variable "namespace" {
  description = "Kubernetes namespace created for the Camunda components."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "hostname" {
  description = "Public hostname of the Camunda web applications and REST API (e.g. 'camunda.example.com')."
  type        = string
}

variable "zeebe_hostname" {
  description = "Public hostname of the Zeebe gRPC API (e.g. 'zeebe.camunda.example.com')."
  type        = string
}

variable "gateway_name" {
  description = "Name of the Gateway (in this module's namespace) that the chart's routes and the Envoy policies attach to."
  type        = string
}

variable "gateway_listener_names" {
  description = "Listener names of the Gateway: web for the HTTPRoutes, grpc for the Zeebe GRPCRoute. The chart's routes use 'https' and 'grpcs'."
  type = object({
    web  = string
    grpc = string
  })
}

variable "keycloak" {
  description = "Keycloak endpoints: public_url as seen by browsers, service_host and service_port of the cluster-internal Service."
  type = object({
    public_url   = string
    service_host = string
    service_port = number
  })
}

variable "keycloak_initial_admin_user" {
  description = "Username of the initial Keycloak admin account."
  type        = string
}

variable "keycloak_initial_admin_password_kv_secret" {
  description = "Name of the KV secret holding the initial Keycloak admin password."
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

variable "opensearch" {
  description = "OpenSearch connection used as secondary storage and by Optimize. The password is read from credentials_kv_secret."
  type = object({
    protocol              = string
    host                  = string
    port                  = number
    username              = string
    credentials_kv_secret = string
  })
}

variable "webmodeler_postgres" {
  description = "PostgreSQL database of Web Modeler. The password is read from credentials_kv_secret."
  type = object({
    host                  = string
    port                  = number
    database              = string
    username              = string
    credentials_kv_secret = string
  })
}

variable "webmodeler_mail_from_address" {
  description = "Sender address of emails sent by Web Modeler. Required by the chart."
  type        = string
}

variable "camunda_initial_user" {
  description = "Initial Camunda user, created on first startup with the admin role."
  type = object({
    username  = string
    email     = string
    firstName = string
    lastName  = string
  })
}

variable "zeebe_config" {
  description = <<-EOT
    Zeebe broker cluster sizing.
    - cluster_size:       Number of brokers.
    - partition_count:    Number of partitions. Should be >= cluster_size for an even distribution.
    - replication_factor: Number of copies per partition. Cannot exceed cluster_size.
    - pvc_size:           Persistent volume per broker (e.g. '10Gi').
  EOT
  type = object({
    cluster_size       = number
    partition_count    = number
    replication_factor = number
    pvc_size           = string
  })

  validation {
    condition     = var.zeebe_config.replication_factor <= var.zeebe_config.cluster_size
    error_message = "replication_factor cannot exceed cluster_size."
  }
}
