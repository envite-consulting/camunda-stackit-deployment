resource "stackit_opensearch_instance" "camunda" {
  project_id = var.project_id
  name       = "camunda-opensearch"
  version    = "2"
  plan_name  = var.opensearch_plan
  parameters = {
    sgw_acl = join(",", stackit_ske_cluster.camunda.egress_address_ranges)
  }
}

resource "stackit_opensearch_credential" "camunda" {
  project_id  = var.project_id
  instance_id = stackit_opensearch_instance.camunda.instance_id
}
