locals {
  public_url = "https://${var.hostname}"

  service_name = "${kubectl_manifest.keycloak.name}-service"
  http_port    = 8080
}

resource "kubectl_manifest" "keycloak" {
  yaml_body = yamlencode({
    apiVersion = "k8s.keycloak.org/v2beta1"
    kind       = "Keycloak"
    metadata = {
      name      = "camunda-keycloak"
      namespace = var.namespace
    }
    spec = {
      instances = 1
      bootstrapAdmin = {
        user = {
          secret = local.initial_admin_credentials_secret
        }
      }
      db = {
        vendor   = "postgres"
        host     = var.postgres_host
        database = var.postgres_database
        usernameSecret = {
          name = local.postgres_credentials_secret
          key  = "username"
        }
        passwordSecret = {
          name = local.postgres_credentials_secret
          key  = "password"
        }
      }

      http = {
        httpEnabled = true
      }

      ingress = {
        enabled = false
      }

      hostname = {
        hostname           = local.public_url
        backchannelDynamic = true
      }

      proxy = {
        headers = "xforwarded"
      }
    }
  })
}

resource "kubectl_manifest" "keycloak_httproute" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "keycloak"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [{
        name        = var.gateway_name
        sectionName = var.gateway_listener_name
      }]
      hostnames = [var.hostname]
      rules = [{
        backendRefs = [{
          name = local.service_name
          port = local.http_port
        }]
      }]
    }
  })
}
