resource "stackit_ske_cluster" "camunda8" {
  project_id             = var.project_id
  name                   = "camunda8"
  kubernetes_version_min = "1.34.2"
  node_pools = [
    {
      name               = "pool1"
      machine_type       = "g2i.16"
      os_name            = "flatcar"
      minimum            = "1"
      maximum            = "1"
      availability_zones = ["eu01-1"]
      volume_type        = "storage_premium_perf2"
    }
  ]
  maintenance = {
    enable_kubernetes_version_updates    = true
    enable_machine_image_version_updates = true
    start                                = "01:00:00Z"
    end                                  = "02:00:00Z"
  }
  extensions = {
    dns = {
      enabled = true
      zones   = [stackit_dns_zone.camunda8.dns_name]
    }
  }
}

