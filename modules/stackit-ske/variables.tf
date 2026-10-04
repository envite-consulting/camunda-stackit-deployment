variable "project_id" {
  description = "STACKIT project ID under which the SKE cluster is created."
  type        = string
}

variable "name" {
  description = "Name of the SKE (STACKIT Kubernetes Engine) cluster."
  type        = string
}

variable "ske_availability_zones" {
  description = "List of STACKIT availability zones across which SKE worker nodes are distributed (e.g. ['eu01-1', 'eu01-2', 'eu01-3'])."
  type        = list(string)

  validation {
    condition     = length(var.ske_availability_zones) > 0
    error_message = "At least one availability zone must be specified."
  }
}

variable "ske_maintenance_window" {
  description = "Maintenance window for SKE cluster upgrades. Times must be in UTC (format: 'HH:MM:SSZ')."
  type = object({
    start = string
    end   = string
  })
}

variable "ske_machine_type" {
  description = "Machine type for SKE worker nodes (e.g. 'g2i.16'). See STACKIT machine type catalogue for available options."
  type        = string
}

variable "ske_volume_type" {
  description = "Block volume type attached to SKE worker nodes (e.g. 'storage_premium_perf2'). Determines IOPS and throughput characteristics."
  type        = string
}

variable "ske_volume_size" {
  description = "Size in GB of the block volume attached to SKE worker nodes. Holds container images, logs and emptyDir data; too small a volume puts the node under disk pressure and blocks scheduling."
  type        = number

  validation {
    condition     = var.ske_volume_size >= 20
    error_message = "ske_volume_size must be at least 20 GB."
  }
}

variable "node_pools_minimum" {
  description = "Minimum number of worker nodes in the SKE node pool. Used as the autoscaler lower bound. Must be a numeric string (e.g. '1')."
  type        = string

  validation {
    condition     = can(tonumber(var.node_pools_minimum))
    error_message = "node_pools_minimum must be a numeric string (e.g. '1')."
  }
}

variable "node_pools_maximum" {
  description = "Maximum number of worker nodes in the SKE node pool. Used as the autoscaler upper bound. Must be a numeric string (e.g. '5')."
  type        = string

  validation {
    condition     = can(tonumber(var.node_pools_maximum))
    error_message = "node_pools_maximum must be a numeric string (e.g. '5')."
  }

  validation {
    condition     = tonumber(var.node_pools_maximum) >= tonumber(var.node_pools_minimum)
    error_message = "node_pools_maximum must be greater than or equal to node_pools_minimum."
  }
}

variable "dns_zones" {
  description = "Names of the STACKIT DNS zones in which the SKE DNS extension (ExternalDNS) may create records."
  type        = list(string)

  validation {
    condition     = length(var.dns_zones) > 0
    error_message = "At least one DNS zone must be specified."
  }
}
