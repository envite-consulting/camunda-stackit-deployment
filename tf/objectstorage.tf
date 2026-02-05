resource "stackit_objectstorage_bucket" "camunda" {
  project_id = var.project_id
  name       = "camunda-backups"
}

resource "stackit_objectstorage_credentials_group" "camunda" {
  project_id = var.project_id
  name       = "camunda_group"
}

resource "stackit_objectstorage_credential" "camunda" {
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.camunda.credentials_group_id
}
