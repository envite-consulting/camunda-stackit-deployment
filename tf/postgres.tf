resource "stackit_postgresflex_instance" "camunda" {
  project_id      = var.project_id
  name            = "camunda-postgres"
  acl             = stackit_ske_cluster.camunda.egress_address_ranges
  backup_schedule = "00 00 * * *"
  flavor = {
    cpu = 2
    ram = 4
  }
  replicas = 1
  storage = {
    class = var.postgres_storage_class
    size  = 5
  }
  version = 17
}

resource "stackit_postgresflex_user" "camunda" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda.instance_id
  username    = var.postgres_user_camunda
  roles       = ["login", "createdb"]
}

resource "stackit_postgresflex_database" "camunda" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda.instance_id
  owner       = stackit_postgresflex_user.camunda.username
  name        = var.postgres_database_camunda
}


resource "stackit_postgresflex_user" "keycloak" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda.instance_id
  username    = var.postgres_user_keycloak
  roles       = ["login", "createdb"]
}

resource "stackit_postgresflex_database" "keycloak" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda.instance_id
  owner       = stackit_postgresflex_user.keycloak.username
  name        = var.postgres_database_keycloak
}