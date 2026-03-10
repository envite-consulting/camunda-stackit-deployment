variable "namespace" {
  description = "Kubernetes namespace in which the Keycloak operator and its CRDs are deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.namespace))
    error_message = "namespace must consist of lowercase alphanumeric characters or hyphens."
  }
}

variable "keycloak_operator_url" {
  description = "URL to the Keycloak Operator manifest (kubernetes.yml). Must point to a specific release tag, not 'latest' or a mutable branch ref."
  type        = string

  validation {
    condition     = startswith(var.keycloak_operator_url, "https://")
    error_message = "keycloak_operator_url must be an HTTPS URL."
  }
}

variable "keycloak_crds_url" {
  description = "URL to the Keycloak CRD manifest (keycloaks.k8s.keycloak.org). Must point to a specific release tag, not 'latest' or a mutable branch ref."
  type        = string

  validation {
    condition     = startswith(var.keycloak_crds_url, "https://")
    error_message = "keycloak_crds_url must be an HTTPS URL."
  }
}

variable "keycloak_crds_realmimports" {
  description = "URL to the Keycloak RealmImport CRD manifest (keycloakrealmimports.k8s.keycloak.org). Must point to a specific release tag, not 'latest' or a mutable branch ref."
  type        = string

  validation {
    condition     = startswith(var.keycloak_crds_realmimports, "https://")
    error_message = "keycloak_crds_realmimports must be an HTTPS URL."
  }
}
