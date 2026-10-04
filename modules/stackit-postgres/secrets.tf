resource "vault_kv_secret_v2" "credentials" {
  mount = var.secret_store_path
  name  = "${var.instance_name}-credentials"

  data_json = jsonencode({
    username = stackit_postgresflex_user.main.username
    password = stackit_postgresflex_user.main.password
  })
}
