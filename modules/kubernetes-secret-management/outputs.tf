output "cluster_secret_store_name" {
  description = "Name of the ClusterSecretStore. ExternalSecrets reference it in secretStoreRef."
  value       = kubectl_manifest.cluster_secret_store.name
}
