resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  name       = var.release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  wait    = true
  timeout = 600

  set = [
    {
      name  = "server.service.type"
      value = var.server_service_type
    },
    {
      name  = "dex.enabled"
      value = var.enable_dex
    },
    {
      name  = "controller.replicas"
      value = "1"
    },
    {
      name  = "server.replicas"
      value = "1"
    },
    {
      name  = "repoServer.replicas"
      value = "1"
    },
    {
      name  = "applicationSet.replicas"
      value = "1"
    }
  ]
}
