resource "kubectl_manifest" "root_redirect" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "camunda-root-redirect"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      parentRefs = [{
        name        = var.gateway_name
        sectionName = var.gateway_listener_names.web
      }]
      hostnames = [var.hostname]
      rules = [{
        matches = [{
          path = {
            type  = "Exact"
            value = "/"
          }
        }]
        filters = [{
          type = "RequestRedirect"
          requestRedirect = {
            path = {
              type            = "ReplaceFullPath"
              replaceFullPath = local.hub_path
            }
            statusCode = 302
          }
        }]
      }]
    }
  })
}
