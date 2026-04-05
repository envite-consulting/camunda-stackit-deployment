locals {
  credentials_kv_secret = "${var.instance_name}-credentials"
}

resource "stackit_postgresflex_instance" "main" {
  project_id      = var.project_id
  name            = var.instance_name
  acl             = var.acl
  backup_schedule = var.backup_schedule
  flavor          = var.postgres_flavor
  replicas        = var.replicas
  storage = {
    class = var.postgres_storage_class
    size  = var.postgres_storage_size
  }
  version = 17
}

resource "stackit_postgresflex_user" "main" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.main.instance_id
  username    = var.postgres_username
  roles       = ["login", "createdb"]
}

resource "stackit_postgresflex_database" "main" {
  for_each = var.database_names

  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.main.instance_id
  owner       = stackit_postgresflex_user.main.username
  name        = each.value
}
