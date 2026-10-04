locals {
  envoy_gateway_namespace = "envoy-gateway-system"
  gateway_class_name      = "envoy"
  cert_manager_namespace  = "cert-manager"
  cluster_issuer_name     = "letsencrypt-production"

  # The Gateway API CRDs are cluster-wide and shared by Envoy Gateway and cert-manager. The standard channel is
  # installed here instead of through the Envoy Gateway chart, which would install the experimental channel from
  # its crds/ directory (never upgraded by Helm).
  gateway_api_crds_url   = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml"
  envoy_gateway_crds_url = "https://github.com/envoyproxy/gateway/releases/download/${var.envoy_gateway_version}/envoy-gateway-crds.yaml"

  stackit_sa_key_file_name = "sa.json"
}

data "http" "gateway_api_crds" {
  url = local.gateway_api_crds_url
}

data "kubectl_file_documents" "gateway_api_crds" {
  content = data.http.gateway_api_crds.response_body
}

resource "kubectl_manifest" "gateway_api_crds" {
  for_each = data.kubectl_file_documents.gateway_api_crds.manifests

  yaml_body         = each.value
  server_side_apply = true
}

data "http" "envoy_gateway_crds" {
  url = local.envoy_gateway_crds_url
}

data "kubectl_file_documents" "envoy_gateway_crds" {
  content = data.http.envoy_gateway_crds.response_body
}

resource "kubectl_manifest" "envoy_gateway_crds" {
  for_each = data.kubectl_file_documents.envoy_gateway_crds.manifests

  yaml_body         = each.value
  server_side_apply = true

  depends_on = [kubectl_manifest.gateway_api_crds]
}

resource "kubernetes_namespace_v1" "envoy_gateway" {
  metadata {
    name = local.envoy_gateway_namespace
  }
}

resource "helm_release" "envoy_gateway" {
  name       = "envoy-gateway"
  repository = "oci://docker.io/envoyproxy"
  chart      = "gateway-helm"
  version    = var.envoy_gateway_version
  namespace  = kubernetes_namespace_v1.envoy_gateway.metadata[0].name

  values = [yamlencode({
    crds = {
      enabled = false
    }
  })]

  depends_on = [kubectl_manifest.envoy_gateway_crds]
}

resource "kubectl_manifest" "gateway_class" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "GatewayClass"
    metadata = {
      name = local.gateway_class_name
    }
    spec = {
      controllerName = "gateway.envoyproxy.io/gatewayclass-controller"
    }
  })

  depends_on = [helm_release.envoy_gateway]
}

resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = local.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name

  values = [yamlencode({
    crds = {
      enabled = true
    }
    config = {
      apiVersion = "controller.config.cert-manager.io/v1alpha1"
      kind       = "ControllerConfiguration"
      gatewayAPI = {
        enabled = true
      }
    }
  })]

  depends_on = [kubectl_manifest.gateway_api_crds]
}

resource "kubernetes_secret_v1" "stackit_sa_key" {
  metadata {
    name      = "stackit-sa-authentication"
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
  }

  data = {
    (local.stackit_sa_key_file_name) = var.stackit_dns_sa_key
  }
}

resource "helm_release" "stackit_cert_manager_webhook" {
  name       = "stackit-cert-manager-webhook"
  repository = "https://stackitcloud.github.io/stackit-cert-manager-webhook"
  chart      = "stackit-cert-manager-webhook"
  version    = var.stackit_cert_manager_webhook_chart_version
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name

  values = [yamlencode({
    stackitSaAuthentication = {
      enabled    = true
      secretName = kubernetes_secret_v1.stackit_sa_key.metadata[0].name
      fileName   = local.stackit_sa_key_file_name
    }
  })]

  depends_on = [helm_release.cert_manager]
}

# DNS-01 instead of HTTP-01: with the Gateway API, HTTP-01 deadlocks on a fresh install. The HTTPS listener is not
# valid without the certificate, the certificate needs a reachable solver, and the solver needs the DNS record.
# DNS-01 only needs the STACKIT DNS API.
resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = local.cluster_issuer_name
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        privateKeySecretRef = {
          name = local.cluster_issuer_name
        }
        solvers = [{
          dns01 = {
            webhook = {
              groupName  = "acme.stackit.de"
              solverName = "stackit"
              config = {
                projectId = var.project_id
              }
            }
          }
        }]
      }
    }
  })

  depends_on = [helm_release.stackit_cert_manager_webhook]
}
