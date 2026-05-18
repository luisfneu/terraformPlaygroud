output "namespace" {
  description = "Namespace onde o External Secrets Operator foi instalado"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}

output "helm_release_status" {
  description = "Status do release Helm"
  value       = helm_release.external_secrets.status
}

output "chart_version" {
  description = "Versão do chart instalada"
  value       = helm_release.external_secrets.version
}
