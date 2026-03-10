resource "vault_kv_secret_v2" "postgres_keycloak" {
  mount = var.secret_store_path
  name  = local.credentials_kv_secret

  data_json = jsonencode({
    username = stackit_postgresflex_user.main.username
    password = stackit_postgresflex_user.main.password
  })
}
