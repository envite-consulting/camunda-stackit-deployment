resource "stackit_objectstorage_bucket" "main" {
  project_id = var.project_id
  name       = var.bucket_name
}

resource "stackit_objectstorage_credentials_group" "main" {
  project_id = var.project_id
  name       = var.credentials_name

  depends_on = [stackit_objectstorage_bucket.main]
}

resource "stackit_objectstorage_credential" "main" {
  project_id           = var.project_id
  credentials_group_id = stackit_objectstorage_credentials_group.main.credentials_group_id
}
