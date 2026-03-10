resource "stackit_ske_cluster" "main" {
  project_id             = var.project_id
  name                   = var.name
  kubernetes_version_min = var.kubernetes_version_min
  node_pools = [
    {
      name               = "pool1"
      machine_type       = var.ske_machine_type
      os_name            = "flatcar"
      minimum            = var.node_pools_minimum
      maximum            = var.node_pools_maximum
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
      zones   = var.dns_zones
    }
  }
}

resource "stackit_ske_kubeconfig" "camunda" {
  project_id   = var.project_id
  cluster_name = stackit_ske_cluster.main.name
  refresh      = true
}

locals {
  kubeconfig = yamldecode(stackit_ske_kubeconfig.camunda.kube_config)
}
