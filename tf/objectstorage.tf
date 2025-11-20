resource "stackit_objectstorage_bucket" "camunda8" {
  project_id = var.project_id
  name       = "camunda8-backups"
}

resource "stackit_objectstorage_credentials_group" "camunda8_group" {
  project_id = var.project_id
  name       = "camunda8_group"
}

resource "stackit_objectstorage_credential" "camunda8_credentials" {
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.camunda8_group.credentials_group_id
}
