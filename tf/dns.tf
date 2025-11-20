resource "stackit_dns_zone" "camunda8" {
  project_id = var.project_id
  dns_name   = var.dns_name
  name       = "Camunda 8 Zone"
}
