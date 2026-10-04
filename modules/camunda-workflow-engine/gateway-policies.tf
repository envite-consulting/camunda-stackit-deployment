locals {
  # Envoy ends every request after a route timeout of 15s when none is set. The stream idle timeout closes
  # streams without traffic (default 5m). See https://www.envoyproxy.io/docs/envoy/latest/faq/configuration/timeouts
  backend_timeouts = {
    # Web applications and REST API. 15s is too short for long-running requests such as REST job activation with
    # long polling. WebSockets of Web Modeler (/modeler-ws) are not affected: the route timeout only starts once
    # the request is complete, and an upgraded connection never completes.
    (var.gateway_listener_names.web) = {
      requestTimeout = "300s"
    }
    # Zeebe gRPC. Job streaming keeps a gRPC stream open that sees no traffic while no jobs are available. Camunda
    # recommends a client stream timeout of 1h and a proxy timeout slightly above it, e.g. 1h10m. See
    # https://docs.camunda.io/docs/self-managed/components/orchestration-cluster/zeebe/zeebe-gateway/job-streaming/
    (var.gateway_listener_names.grpc) = {
      requestTimeout    = "0s" # disabled, streams and long polls are open-ended
      streamIdleTimeout = "70m"
    }
  }
}

resource "kubectl_manifest" "backend_traffic_policy" {
  for_each = local.backend_timeouts

  yaml_body = yamlencode({
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "BackendTrafficPolicy"
    metadata = {
      name      = "camunda-${each.key}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      targetRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = var.gateway_name
        sectionName = each.key
      }]
      timeout = {
        http = each.value
      }
    }
  })
}

resource "kubectl_manifest" "grpc_client_traffic_policy" {
  yaml_body = yamlencode({
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "ClientTrafficPolicy"
    metadata = {
      name      = "camunda-${var.gateway_listener_names.grpc}"
      namespace = kubernetes_namespace_v1.camunda.metadata[0].name
    }
    spec = {
      targetRefs = [{
        group       = "gateway.networking.k8s.io"
        kind        = "Gateway"
        name        = var.gateway_name
        sectionName = var.gateway_listener_names.grpc
      }]
      tls = {
        alpnProtocols = ["h2", "http/1.1"]
      }
    }
  })
}
