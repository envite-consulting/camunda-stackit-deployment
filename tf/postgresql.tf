resource "stackit_postgresflex_instance" "camunda8" {
  project_id      = var.project_id
  name            = "camunda-postgres"
  acl             = stackit_ske_cluster.camunda8.egress_address_ranges
  backup_schedule = "00 00 * * *"
  flavor = {
    cpu = 2
    ram = 4
  }
  replicas = 1
  storage = {
    class = "premium-perf6-stackit"
    size  = 5
  }
  version = 17
}

resource "stackit_postgresflex_user" "camunda8_user" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda8.instance_id
  username    = "camunda_user"
  roles       = ["login", "createdb"]
}

resource "stackit_postgresflex_database" "camunda8_db" {
  project_id  = var.project_id
  instance_id = stackit_postgresflex_instance.camunda8.instance_id
  owner       = stackit_postgresflex_user.camunda8_user.username
  name        = "camunda8"
}
