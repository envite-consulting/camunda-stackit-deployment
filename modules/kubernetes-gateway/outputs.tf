output "gateway_class_name" {
  description = "Name of the Envoy Gateway GatewayClass. Gateways select it via gatewayClassName."
  value       = kubectl_manifest.gateway_class.name
}

output "cluster_issuer" {
  description = "Name of the Let's Encrypt ClusterIssuer (STACKIT DNS-01). Gateways reference it via the cert-manager.io/cluster-issuer annotation."
  value       = kubectl_manifest.cluster_issuer.name
}
