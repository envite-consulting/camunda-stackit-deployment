resource "stackit_dns_zone" "main" {
  project_id = var.project_id
  dns_name   = var.dns_name
  name       = var.name
}
