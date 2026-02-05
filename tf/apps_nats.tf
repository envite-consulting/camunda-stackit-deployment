locals {
  nats_values = {
    config = {
      cluster = {
        enabled  = true
        replicas = 1
      }
    }
    podTemplate = {
      topologySpreadConstraints = {
        "kubernetes.io/hostname" = {
          maxSkew : 1
          whenUnsatisfiable : "ScheduleAnyway"
        }
      }
    }
  }
}

resource "helm_release" "nats" {
  name             = "nats"
  repository       = "https://nats-io.github.io/k8s/helm/charts/"
  chart            = "nats"
  namespace        = var.namespace_nats
  version          = "1.3.3"
  create_namespace = true

  values = [
    yamlencode(local.nats_values)
  ]
}
