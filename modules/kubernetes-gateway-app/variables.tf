variable "name" {
  description = "Name of the Gateway."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.name)) && length(var.name) <= 57
    error_message = "name must be a DNS-1123 label of at most 57 characters, so that the derived names stay within 63 characters."
  }
}

variable "namespace" {
  description = "Existing namespace for the Gateway and its EnvoyProxy. Routes attaching to the Gateway must live in the same namespace."
  type        = string
}

variable "gateway_class_name" {
  description = "Name of the Envoy Gateway GatewayClass the Gateway is served by."
  type        = string
}

variable "cluster_issuer" {
  description = "Name of the cert-manager ClusterIssuer that issues the certificate for the HTTPS listeners."
  type        = string
}

variable "listeners" {
  description = "HTTPS listeners (port 443, TLS terminated at the Gateway) as a map of listener name to public hostname. Routes reference the listener name as sectionName."
  type        = map(string)
}
