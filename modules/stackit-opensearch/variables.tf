variable "project_id" {
  description = "STACKIT project ID under which the OpenSearch instance is created."
  type        = string
}

variable "name" {
  description = "Name of the STACKIT OpenSearch service instance."
  type        = string
}

variable "opensearch_plan" {
  description = "STACKIT OpenSearch service plan identifier (e.g. 'stackit-opensearch-1.4.10-single'). Determines node size, storage, and availability. See STACKIT catalogue for available plans."
  type        = string
}

variable "acl" {
  description = "List of CIDR ranges allowed to reach the OpenSearch instance. Should contain the SKE node egress IPs to permit cluster-internal access."
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.acl : can(cidrhost(cidr, 0))])
    error_message = "All entries in acl must be valid CIDR ranges (e.g. '185.0.0.1/32')."
  }
}

variable "secret_store_path" {
  description = "Mount path of the Secrets Manager KV engine (the Secrets Manager instance ID) to write the credentials to."
  type        = string
}
