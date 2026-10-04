variable "project_id" {
  description = "STACKIT project ID that owns the DNS zone used for ACME DNS-01 challenges."
  type        = string
}

variable "stackit_dns_sa_key" {
  description = "Content of the STACKIT service account key (JSON) the DNS-01 webhook uses to manage TXT records in the project's DNS zone."
  type        = string
  sensitive   = true

  validation {
    condition     = can(jsondecode(var.stackit_dns_sa_key))
    error_message = "stackit_dns_sa_key must be valid JSON (a STACKIT service account key file)."
  }
}
