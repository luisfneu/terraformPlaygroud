variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "source_account_id" {
  type        = string
}

variable "target_provider_role_arn" {
  description = "role ARN para gerenciar destino"
  type        = string
  default     = "arn:aws:iam::178520105998:role/TerraformBootstrap"
}

variable "source_provider_role_arn" {
  description = "role ARN para gerenciar a origem"
  type        = string
  default     = "arn:aws:iam::443370700365:role/TerraformBootstrap"
}

variable "admin_role_name" {
  type        = string
  default     = "CrossAccountAdmin"
}

variable "max_session_duration" {
  type        = number
  default     = 3600
}

variable "require_mfa" {
  type        = bool
  default     = false
}

variable "allowed_principal_arns" {
  type        = list(string)
  default     = []
}

variable "admin_group_name" {
  type        = string
  default     = "cross-account-admins"
}

variable "create_source_group" {
  type        = bool
  default     = true
}
