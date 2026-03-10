variable "project_id" {
  description = "STACKIT project ID under which the DNS zone is created."
  type        = string
}

variable "name" {
  description = "Human-readable name of the STACKIT DNS zone resource (e.g. 'camunda-prod')."
  type        = string
}

variable "dns_name" {
  description = "Fully qualified domain name (FQDN) of the DNS zone. Must end with a trailing dot (e.g. 'camunda.example.com.')."
  type        = string
}
