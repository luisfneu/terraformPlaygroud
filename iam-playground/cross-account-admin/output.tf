output "admin_role_arn" {
  description = "ARN da role de admin na conta destino (use no sts:AssumeRole)"
  value       = aws_iam_role.admin.arn
}

output "admin_group_name" {
  description = "Grupo na conta origem cujos membros podem assumir a role"
  value       = var.create_source_group ? aws_iam_group.admins[0].name : null
}

output "assume_role_command" {
  description = "Exemplo de comando para assumir a role"
  value       = "aws sts assume-role --role-arn ${aws_iam_role.admin.arn} --role-session-name admin-session"
}
