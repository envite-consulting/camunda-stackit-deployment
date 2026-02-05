locals {
  kubeconfig = yamldecode(
    stackit_ske_kubeconfig.ske_kubeconfig.kube_config
  )

  kube_host = local.kubeconfig.clusters[0].cluster.server

  kube_certificate_authority = base64decode(
    local.kubeconfig.clusters[0].cluster["certificate-authority-data"]
  )

  kube_client_certificate = base64decode(
    local.kubeconfig.users[0].user["client-certificate-data"]
  )

  kube_client_key = base64decode(
    local.kubeconfig.users[0].user["client-key-data"]
  )
}

resource "stackit_ske_kubeconfig" "ske_kubeconfig" {
  project_id   = var.project_id
  cluster_name = stackit_ske_cluster.camunda.name
  refresh      = true
}
