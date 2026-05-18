resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.chart_version
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  wait    = true
  timeout = 600

  set = [
    {
      name  = "installCRDs"
      value = var.install_crds
    },
    {
      name  = "replicaCount"
      value = "1"
    },
    {
      name  = "webhook.replicaCount"
      value = "1"
    },
    {
      name  = "certController.replicaCount"
      value = "1"
    }
  ]
}
