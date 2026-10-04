output "dns_name" {
  description = "Name of the DNS zone (e.g. 'camunda.example.com')."
  value       = stackit_dns_zone.main.dns_name
}
