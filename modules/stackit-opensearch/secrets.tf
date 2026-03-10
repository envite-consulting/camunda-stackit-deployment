resource "vault_kv_secret_v2" "opensearch_camunda" {
  mount = var.secret_store_path
  name  = local.credentials_secret

  data_json = jsonencode({
    password = stackit_opensearch_credential.main.password
  })
}
