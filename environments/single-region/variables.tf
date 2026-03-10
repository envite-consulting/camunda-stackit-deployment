variable "project_id" {
  description = "STACKIT project ID used to scope all resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g. 'dev', 'staging', 'prod'). Used for resource naming and tagging."
  type        = string
}

variable "stackit_region" {
  description = "STACKIT region in which all resources are provisioned."
  type        = string
  default     = "eu01"
}

variable "dns_name" {
  description = "Public DNS name used for Camunda ingress (e.g. 'camunda.example.com')."
  type        = string
}

variable "kubernetes_version_min" {
  description = "Minimum Kubernetes version for the SKE cluster."
  type        = string
  default     = "1.34"
}

variable "ske_machine_type" {
  description = "Machine type for SKE worker nodes (see STACKIT machine type catalogue)."
  type        = string
  default     = "g2i.16"
}

variable "ske_volume_type" {
  description = "Block volume type attached to SKE worker nodes."
  type        = string
  default     = "storage_premium_perf2"
}

variable "ske_availability_zones" {
  description = "List of STACKIT availability zones in which SKE worker nodes are distributed."
  type        = list(string)
  default     = ["eu01-1"]
}

variable "ske_maintenance_window" {
  description = "Maintenance window for SKE cluster upgrades. Times must be in UTC (format: 'HH:MM:SSZ')."
  type = object({
    start = string
    end   = string
  })
  default = {
    start = "01:00:00Z"
    end   = "02:00:00Z"
  }
}

variable "node_pools_minimum" {
  description = "Minimum number of worker nodes in the SKE node pool (used for autoscaling)."
  type        = string
  default     = "1"
}

variable "node_pools_maximum" {
  description = "Maximum number of worker nodes in the SKE node pool (used for autoscaling)."
  type        = string
  default     = "1"
}

variable "keycloak_initial_admin_username" {
  description = "Username for the initial Keycloak admin user ('admin')."
  type        = string
}

variable "keycloak_realm" {
  description = "Name of the Keycloak realm used for Camunda OIDC authentication (e.g. 'camunda-platform')."
  type        = string
  default     = "camunda-platform"
}

variable "camunda_initial_user" {
  description = "Initial Camunda platform user created on first startup. All fields are required."
  type = object({
    username  = string
    email     = string
    firstName = string
    lastName  = string
  })
}

variable "zeebe_config" {
  description = "Zeebe broker sizing configuration. Increase replication_factor and partition_count for production clusters."
  type = object({
    replicas           = number
    replication_factor = string
    partition_count    = string
    pvc_size_gb        = string
  })
  default = {
    replicas           = 1
    replication_factor = "1"
    partition_count    = "1"
    pvc_size_gb        = "10Gi"
  }
}

variable "postgres_flavor" {
  description = "CPU and RAM allocation for the PostgreSQL instance."
  type = object({
    cpu = number
    ram = number
  })
  default = {
    cpu = 2
    ram = 4
  }
}

variable "postgres_storage_class" {
  description = "Kubernetes storage class used for PostgreSQL PersistentVolumeClaims."
  type        = string
  default     = "premium-perf6-stackit"
}

variable "postgres_storage_size" {
  description = "Size of the PostgreSQL data volume in gigabytes."
  type        = number
  default     = 5
}

variable "replicas" {
  description = "Number of PostgreSQL replicas. Set to 1 for dev, 2+ for production high availability."
  type        = number
  default     = 1
}

variable "backup_schedule" {
  description = "Cron expression defining the PostgreSQL backup schedule (UTC). Default: daily at midnight."
  type        = string
  default     = "0 0 * * *"
}

variable "opensearch_plan" {
  description = "STACKIT OpenSearch service plan identifier. See STACKIT catalogue for available plans."
  type        = string
  default     = "stackit-opensearch-1.4.10-single"
}

variable "sa_key_file_name" {
  description = "Path to the STACKIT service account key file (JSON) used for provider authentication."
  type        = string
  default     = "sa_key.json"
}
