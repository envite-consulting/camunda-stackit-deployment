locals {
  credentials_secret = "opensearch-credentials"
}

resource "stackit_opensearch_instance" "main" {
  project_id = var.project_id
  name       = var.name
  version    = "2"
  plan_name  = var.opensearch_plan
  parameters = {
    sgw_acl = join(",", var.acl)
  }
}

resource "stackit_opensearch_credential" "main" {
  project_id  = var.project_id
  instance_id = stackit_opensearch_instance.main.instance_id
}

