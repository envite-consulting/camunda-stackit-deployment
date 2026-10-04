resource "stackit_secretsmanager_instance" "main" {
  project_id = var.project_id
  name       = var.name
}

# The vault provider logs in with this user once per Terraform run, and the token it gets expires. If the user (and
# with it the login) came early in a fresh apply, the token would expire before the credentials of the database
# instances, which take long to create, are written (403 permission denied). Creating the user after those instances
# keeps the login close to the writes.
resource "terraform_data" "user_after" {
  input = var.create_user_after
}

resource "stackit_secretsmanager_user" "main" {
  project_id    = var.project_id
  instance_id   = stackit_secretsmanager_instance.main.instance_id
  description   = "Terraform automation user"
  write_enabled = true

  depends_on = [terraform_data.user_after]
}
