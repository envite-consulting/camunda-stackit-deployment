resource "kubectl_manifest" "envoy_proxy" {
  yaml_body = yamlencode({
    apiVersion = "gateway.envoyproxy.io/v1alpha1"
    kind       = "EnvoyProxy"
    metadata = {
      name      = "${var.name}-envoy"
      namespace = var.namespace
    }
    spec = {
      provider = {
        type = "Kubernetes"
        kubernetes = {
          envoyService = {
            annotations = {
              # DNS: the ExternalDNS managed by the SKE DNS extension creates the A records from this annotation on
              # the LoadBalancer Service, which Envoy Gateway generates (under a hashed name) and annotates from here.
              # Its Gateway API source (routes) did not create any records, so do not switch to route-based DNS.
              "external-dns.alpha.kubernetes.io/hostname" = join(",", values(var.listeners))
            }
          }
        }
      }
    }
  })
}

resource "kubectl_manifest" "gateway" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.name
      namespace = var.namespace
      annotations = {
        "cert-manager.io/cluster-issuer" = var.cluster_issuer
      }
    }
    spec = {
      gatewayClassName = var.gateway_class_name
      infrastructure = {
        parametersRef = {
          group = "gateway.envoyproxy.io"
          kind  = "EnvoyProxy"
          name  = kubectl_manifest.envoy_proxy.name
        }
      }
      listeners = [
        for name, hostname in var.listeners : {
          name     = name
          port     = 443
          protocol = "HTTPS"
          hostname = hostname
          tls = {
            mode            = "Terminate"
            certificateRefs = [{ name = "${var.name}-tls" }]
          }
        }
      ]
    }
  })
}
