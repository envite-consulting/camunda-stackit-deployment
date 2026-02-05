resource "stackit_dns_zone" "camunda" {
  project_id = var.project_id
  dns_name   = var.dns_name
  name       = "Camunda Zone"
}


