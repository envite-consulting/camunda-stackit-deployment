locals {
  cert_manager_cluster_issuer = "letsencrypt-production"
  keycloak_namespace          = "keycloak"
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
  ske_availability_zones = var.ske_availability_zones
  ske_maintenance_window = var.ske_maintenance_window
  dns_zones              = [var.dns_name]
  node_pools_maximum     = var.node_pools_maximum
  node_pools_minimum     = var.node_pools_minimum
  kubernetes_version_min = var.kubernetes_version_min
}

module "stackit_postgres" {
  source                 = "../../modules/stackit-postgres"
  project_id             = var.project_id
  acl                    = module.stackit_ske.egress_address_ranges
  postgres_flavor        = var.postgres_flavor
  postgres_storage_class = var.postgres_storage_class
  postgres_storage_size  = var.postgres_storage_size
  replicas               = var.replicas
  secret_store_path      = module.stackit_secrets_manager.instance_id
  depends_on             = [module.stackit_secrets_manager]
  backup_schedule        = var.backup_schedule
  database_names         = ["keycloak"]
  instance_name          = "keycloak-postgres-${var.environment}"
  postgres_username      = "postgres-user"
}

module "stackit_object_storage" {
  source           = "../../modules/stackit-object-storage"
  project_id       = var.project_id
  bucket_name      = "camunda-backups-${var.environment}"
  credentials_name = "camunda-group-${var.environment}"
}

module "stackit_secrets_manager" {
  source            = "../../modules/stackit-secrets-manager"
  project_id        = var.project_id
  namespace         = "secrets-manager"
  name              = "camunda-secrets-${var.environment}"
  secret_store_path = module.stackit_secrets_manager.instance_id
  depends_on        = [module.kubernetes_secret_management]
}

module "stackit_opensearch" {
  source            = "../../modules/stackit-opensearch"
  project_id        = var.project_id
  name              = "camunda-opensearch-${var.environment}"
  opensearch_plan   = var.opensearch_plan
  acl               = module.stackit_ske.egress_address_ranges
  secret_store_path = module.stackit_secrets_manager.instance_id
  depends_on        = [module.stackit_secrets_manager]
}

module "kubernetes_ingress" {
  source                      = "../../modules/kubernetes-ingress"
  cert_manager_cluster_issuer = local.cert_manager_cluster_issuer
  ingress_namespace           = "ingress-nginx"
  cert_manager_namespace      = "cert-manager"
}

module "kubernetes_secret_management" {
  source    = "../../modules/kubernetes-secret-management"
  namespace = "external-secrets-system"
}

module "kubernetes_messaging" {
  source    = "../../modules/kubernetes-messaging"
  namespace = "nats"
}


module "keycloak_operator_bootstrap" {
  source = "../../modules/keycloak-operator-bootstrap"

  namespace                  = local.keycloak_namespace
  keycloak_crds_url          = local.keycloak_crds_url
  keycloak_crds_realmimports = local.keycloak_crds_realmimports
  keycloak_operator_url      = local.keycloak_operator_url
}

module "kubernetes_identity_management" {
  source                         = "../../modules/kubernetes-identity-management"
  namespace                      = local.keycloak_namespace
  name                           = "camunda-keycloak"
  dns_name                       = var.dns_name
  hostname_prefix                = "keycloak"
  service_name                   = "camunda-keycloak-service"
  cert_manager_cluster_issuer    = local.cert_manager_cluster_issuer
  postgres_host                  = module.stackit_postgres.db_host
  postgres_credentials_kv_secret = module.stackit_postgres.postgres_credentials_kv_secret
  secret_store_path              = module.stackit_secrets_manager.instance_id
  initial_admin_name             = var.keycloak_initial_admin_username
  depends_on = [
    module.kubernetes_ingress,
    module.kubernetes_secret_management,
    module.keycloak_operator_bootstrap,
    module.stackit_postgres
  ]
}

module "camunda_workflow_engine" {
  source                                    = "../../modules/camunda-workflow-engine"
  namespace                                 = "camunda"
  dns_name                                  = var.dns_name
  cert_manager_cluster_issuer               = local.cert_manager_cluster_issuer
  camunda_platform_chart_version            = var.camunda_helm_version
  opensearch_host                           = module.stackit_opensearch.host
  opensearch_port                           = module.stackit_opensearch.port
  opensearch_username                       = module.stackit_opensearch.username
  keycloak_service_host                     = module.kubernetes_identity_management.keycloak_service_host
  keycloak_initial_admin_user               = var.keycloak_initial_admin_username
  keycloak_initial_admin_password_kv_secret = module.kubernetes_identity_management.initial_admin_password_kv_secret
  camunda_initial_user                      = var.camunda_initial_user
  secret_store_path                         = module.stackit_secrets_manager.instance_id
  opensearch_credentials_kv_secret          = module.stackit_opensearch.credentials_kv_secret
  zeebe_config                              = var.zeebe_config
  keycloak_realm                            = var.keycloak_realm
  depends_on = [
    module.kubernetes_identity_management,
    module.kubernetes_messaging
  ]
}


