variable "project_id" {
  description = "STACKIT project ID under which the DNS zone is created."
  type        = string
}

variable "name" {
  description = "Human-readable name of the STACKIT DNS zone resource (e.g. 'camunda-prod')."
  type        = string
}

variable "dns_name" {
  description = "Name of the DNS zone (e.g. 'camunda.example.com'). The zone must be delegated to the STACKIT name servers."
  type        = string
}
