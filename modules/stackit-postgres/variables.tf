variable "project_id" {
  description = "STACKIT project ID under which the PostgreSQL instance is created."
  type        = string
}

variable "instance_name" {
  description = "Name of the STACKIT PostgreSQL service instance."
  type        = string
}

variable "postgres_flavor" {
  description = "CPU and RAM allocation for the PostgreSQL instance. See STACKIT catalogue for available combinations."
  type = object({
    cpu = number
    ram = number
  })

  validation {
    condition     = var.postgres_flavor.cpu > 0 && var.postgres_flavor.ram > 0
    error_message = "postgres_flavor.cpu and postgres_flavor.ram must both be greater than 0."
  }
}

variable "postgres_storage_class" {
  description = "STACKIT storage class for the PostgreSQL data volume (e.g. 'premium-perf6-stackit'). Determines IOPS and throughput characteristics."
  type        = string
}

variable "postgres_storage_size" {
  description = "Size of the PostgreSQL data volume in gigabytes."
  type        = number

  validation {
    condition     = var.postgres_storage_size >= 5
    error_message = "postgres_storage_size must be at least 5 GB."
  }
}

variable "replicas" {
  description = "Number of PostgreSQL replicas. Use 1 for dev/single-node, 2 or more for production high availability."
  type        = number

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least 1."
  }
}

variable "backup_schedule" {
  description = "Cron expression defining the PostgreSQL backup schedule (UTC). Example: '0 0 * * *' for daily at midnight."
  type        = string

  validation {
    condition     = can(regex("^([0-9*,/-]+\\s){4}[0-9*,/-]+$", var.backup_schedule))
    error_message = "backup_schedule must be a valid 5-field cron expression (e.g. '0 0 * * *')."
  }
}

variable "postgres_username" {
  description = "Name of the PostgreSQL user created for application access. The corresponding password is managed via ESO."
  type        = string
}

variable "database_names" {
  description = "Set of PostgreSQL database names to create within the instance. Each entry results in a dedicated database."
  type        = set(string)

  validation {
    condition     = length(var.database_names) > 0
    error_message = "At least one database name must be provided."
  }
}

variable "acl" {
  description = "List of CIDR ranges allowed to reach the PostgreSQL instance. Should contain the SKE node egress IPs to permit cluster-internal access."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.acl : can(cidrhost(cidr, 0))])
    error_message = "All entries in acl must be valid CIDR ranges (e.g. '185.0.0.1/32')."
  }
}

variable "secret_store_path" {
  description = "Name of the ESO ClusterSecretStore used to resolve ExternalSecret references within this module."
  type        = string
}
