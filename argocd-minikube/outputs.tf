output "namespace" {
  description = "Namespace onde o Argo CD foi instalado"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "helm_release_status" {
  description = "Status do release Helm"
  value       = helm_release.argocd.status
}

output "chart_version" {
  description = "Versão do chart instalada"
  value       = helm_release.argocd.version
}

output "initial_admin_password_cmd" {
  description = "Comando para obter a senha inicial do usuário admin"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "port_forward_cmd" {
  description = "Comando para acessar a UI em https://localhost:8080"
  value       = "kubectl -n ${kubernetes_namespace.argocd.metadata[0].name} port-forward svc/${var.release_name}-server 8080:443"
}
