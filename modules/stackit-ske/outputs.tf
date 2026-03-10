output "kubeconfig" {
  description = "The kubeconfig details of the SKE cluster"
  value = {
    host                   = local.kubeconfig["clusters"][0]["cluster"]["server"]
    cluster_ca_certificate = local.kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"]
    client_certificate     = local.kubeconfig["users"][0]["user"]["client-certificate-data"]
    client_key             = local.kubeconfig["users"][0]["user"]["client-key-data"]
  }
  sensitive = true
}

output "egress_address_ranges" {
  description = "The egress address ranges of the SKE cluster"
  value       = stackit_ske_cluster.main.egress_address_ranges
}
