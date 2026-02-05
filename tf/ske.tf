resource "stackit_ske_cluster" "camunda" {
  project_id             = var.project_id
  name                   = "camunda"
  kubernetes_version_min = "1.34.3"
  node_pools = [
    {
      name               = "pool1"
      machine_type       = var.ske_machine_type
      os_name            = "flatcar"
      minimum            = "1"
      maximum            = "1"
      availability_zones = var.ske_availability_zones
      volume_type        = var.ske_volume_type
    }
  ]
  maintenance = {
    enable_kubernetes_version_updates    = true
    enable_machine_image_version_updates = true
    start                                = var.ske_maintenance_window.start
    end                                  = var.ske_maintenance_window.end
  }
  extensions = {
    dns = {
      enabled = true
      zones   = [stackit_dns_zone.camunda.dns_name]
    }
  }
}