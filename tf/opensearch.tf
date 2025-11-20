resource "stackit_opensearch_instance" "camunda8" {
  project_id = var.project_id
  name       = "camunda-opensearch"
  version    = "2"
  plan_name  = "stackit-opensearch-1.4.10-single"
}

resource "stackit_opensearch_credential" "camunda8_credential" {
  project_id  = var.project_id
  instance_id = stackit_opensearch_instance.camunda8.instance_id
}
