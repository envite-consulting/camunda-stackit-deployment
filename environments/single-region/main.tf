locals {
  camunda_hostname  = var.dns_name
  zeebe_hostname    = "zeebe.${var.dns_name}"
  keycloak_hostname = "keycloak.${var.dns_name}"

  camunda_listeners = {
    web  = "https"
    grpc = "grpcs"
  }
  keycloak_listener = "https"
}

module "stackit_dns" {
  source     = "../../modules/stackit-dns"
  project_id = var.project_id
  name       = "Camunda Zone"
  dns_name   = var.dns_name
}

module "stackit_ske" {
  source                 = "../../modules/stackit-ske"
  project_id             = var.project_id
  name                   = substr("c8-${var.environment}", 0, 11)
  ske_machine_type       = var.ske_machine_type
  ske_volume_type        = var.ske_volume_type
  ske_volume_size        = var.ske_volume_size
  ske_availability_zones = var.ske_availability_zones
  ske_maintenance_window = var.ske_maintenance_window
  dns_zones              = [module.stackit_dns.dns_name]
  node_pools_maximum     = var.node_pools_maximum
  node_pools_minimum     = var.node_pools_minimum
  kubernetes_version_min = var.kubernetes_version_min
}

module "stackit_secrets_manager" {
  source     = "../../modules/stackit-secrets-manager"
  project_id = var.project_id
  name       = "camunda-secrets-${var.environment}"
  create_user_after = [
    module.stackit_postgres_keycloak.db_username,
    module.stackit_postgres_webmodeler.db_username,
    module.stackit_opensearch.username,
  ]
}

module "stackit_postgres_keycloak" {
  source                 = "../../modules/stackit-postgres"
  project_id             = var.project_id
  acl                    = module.stackit_ske.egress_address_ranges
  postgres_flavor        = var.postgres_flavor
  postgres_storage_class = var.postgres_storage_class
  postgres_storage_size  = var.postgres_storage_size
  replicas               = var.replicas
  secret_store_path      = module.stackit_secrets_manager.instance_id
  backup_schedule        = var.backup_schedule
  database_names         = ["keycloak"]
  instance_name          = "keycloak-postgres-${var.environment}"
  postgres_username      = "postgres-user"
}

module "stackit_postgres_webmodeler" {
  source                 = "../../modules/stackit-postgres"
  project_id             = var.project_id
  acl                    = module.stackit_ske.egress_address_ranges
  postgres_flavor        = var.postgres_flavor
  postgres_storage_class = var.postgres_storage_class
  postgres_storage_size  = var.postgres_storage_size
  replicas               = var.replicas
  secret_store_path      = module.stackit_secrets_manager.instance_id
  backup_schedule        = var.backup_schedule
  database_names         = ["webmodeler"]
  instance_name          = "webmodeler-postgres-${var.environment}"
  postgres_username      = "postgres-user"
}

module "stackit_opensearch" {
  source            = "../../modules/stackit-opensearch"
  project_id        = var.project_id
  name              = "camunda-opensearch-${var.environment}"
  opensearch_plan   = var.opensearch_plan
  acl               = module.stackit_ske.egress_address_ranges
  secret_store_path = module.stackit_secrets_manager.instance_id
}

module "stackit_object_storage" {
  source           = "../../modules/stackit-object-storage"
  project_id       = var.project_id
  bucket_name      = "camunda-backups-${var.environment}"
  credentials_name = "camunda-group-${var.environment}"
}

module "kubernetes_gateway" {
  source             = "../../modules/kubernetes-gateway"
  project_id         = var.project_id
  stackit_dns_sa_key = file(var.cert_manager_sa_key_file_name)
}

module "kubernetes_secret_management" {
  source    = "../../modules/kubernetes-secret-management"
  namespace = "external-secrets-system"
  secrets_manager = {
    vault_address = local.secrets_manager_vault_address
    instance_id   = module.stackit_secrets_manager.instance_id
    username      = module.stackit_secrets_manager.user_username
  }
  secrets_manager_password = module.stackit_secrets_manager.user_password
}

module "kubernetes_messaging" {
  source    = "../../modules/kubernetes-messaging"
  namespace = "nats"
}

module "keycloak_operator_bootstrap" {
  source    = "../../modules/keycloak-operator-bootstrap"
  namespace = "keycloak"
}

module "keycloak_gateway" {
  source             = "../../modules/kubernetes-gateway-app"
  name               = "keycloak-gateway"
  namespace          = module.keycloak_operator_bootstrap.namespace
  gateway_class_name = module.kubernetes_gateway.gateway_class_name
  cluster_issuer     = module.kubernetes_gateway.cluster_issuer
  listeners = {
    (local.keycloak_listener) = local.keycloak_hostname
  }

  depends_on = [module.kubernetes_gateway]
}

module "kubernetes_identity_management" {
  source                         = "../../modules/kubernetes-identity-management"
  namespace                      = module.keycloak_operator_bootstrap.namespace
  hostname                       = local.keycloak_hostname
  gateway_name                   = module.keycloak_gateway.gateway_name
  gateway_listener_name          = local.keycloak_listener
  postgres_host                  = module.stackit_postgres_keycloak.db_host
  postgres_database              = one(module.stackit_postgres_keycloak.database_names)
  postgres_credentials_kv_secret = module.stackit_postgres_keycloak.postgres_credentials_kv_secret
  secret_store_path              = module.stackit_secrets_manager.instance_id
  cluster_secret_store_name      = module.kubernetes_secret_management.cluster_secret_store_name
  initial_admin_name             = var.keycloak_initial_admin_username

  depends_on = [
    module.keycloak_operator_bootstrap,
    module.stackit_postgres_keycloak,
    module.kubernetes_secret_management
  ]
}

module "camunda_gateway" {
  source             = "../../modules/kubernetes-gateway-app"
  name               = "camunda-gateway"
  namespace          = module.camunda_workflow_engine.namespace
  gateway_class_name = module.kubernetes_gateway.gateway_class_name
  cluster_issuer     = module.kubernetes_gateway.cluster_issuer
  listeners = {
    (local.camunda_listeners.web)  = local.camunda_hostname
    (local.camunda_listeners.grpc) = local.zeebe_hostname
  }

  depends_on = [module.kubernetes_gateway]
}

module "camunda_workflow_engine" {
  source                 = "../../modules/camunda-workflow-engine"
  namespace              = "camunda"
  hostname               = local.camunda_hostname
  zeebe_hostname         = local.zeebe_hostname
  gateway_name           = module.camunda_gateway.gateway_name
  gateway_listener_names = local.camunda_listeners
  keycloak = {
    public_url   = module.kubernetes_identity_management.public_url
    service_host = module.kubernetes_identity_management.service_host
    service_port = module.kubernetes_identity_management.service_port
  }
  keycloak_initial_admin_user               = var.keycloak_initial_admin_username
  keycloak_initial_admin_password_kv_secret = module.kubernetes_identity_management.initial_admin_password_kv_secret
  secret_store_path                         = module.stackit_secrets_manager.instance_id
  cluster_secret_store_name                 = module.kubernetes_secret_management.cluster_secret_store_name
  opensearch = {
    protocol              = module.stackit_opensearch.protocol
    host                  = module.stackit_opensearch.host
    port                  = module.stackit_opensearch.port
    username              = module.stackit_opensearch.username
    credentials_kv_secret = module.stackit_opensearch.credentials_kv_secret
  }
  webmodeler_postgres = {
    host                  = module.stackit_postgres_webmodeler.db_host
    port                  = module.stackit_postgres_webmodeler.db_port
    database              = one(module.stackit_postgres_webmodeler.database_names)
    username              = module.stackit_postgres_webmodeler.db_username
    credentials_kv_secret = module.stackit_postgres_webmodeler.postgres_credentials_kv_secret
  }
  webmodeler_mail_from_address = var.webmodeler_mail_from_address
  camunda_initial_user         = var.camunda_initial_user
  zeebe_config                 = var.zeebe_config

  depends_on = [
    module.stackit_postgres_webmodeler,
    module.kubernetes_messaging,
    module.kubernetes_secret_management,
    module.kubernetes_identity_management
  ]
}
