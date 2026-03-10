variable "ingress_namespace" {
  description = "Kubernetes namespace in which the ingress controller (e.g. ingress-nginx) is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.ingress_namespace))
    error_message = "ingress_namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "cert_manager_namespace" {
  description = "Kubernetes namespace in which cert-manager is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cert_manager_namespace))
    error_message = "cert_manager_namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "cert_manager_cluster_issuer" {
  description = "Name of the cert-manager ClusterIssuer used to provision TLS certificates (e.g. 'letsencrypt-prod'). Must exist in the cluster before this module is applied."
  type        = string
}
