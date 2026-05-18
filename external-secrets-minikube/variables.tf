variable "kubeconfig_path" {
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  default     = "minikube"
}

variable "namespace" {
  type        = string
  default     = "external-secrets"
}

variable "chart_version" {
  type        = string
  default     = "0.10.4"
}

variable "install_crds" {
  type        = bool
  default     = true
}
