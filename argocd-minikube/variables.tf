variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "kube_context" {
  type    = string
  default = "minikube"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "9.5.14"
}

variable "release_name" {
  type    = string
  default = "argocd"
}

variable "server_service_type" {
  description = "Tipo de Service do argocd-server (ClusterIP usa port-forward)"
  type        = string
  default     = "ClusterIP"
}

variable "enable_dex" {
  description = "Habilita o Dex (SSO). Desligado para um setup local simples"
  type        = bool
  default     = false
}
