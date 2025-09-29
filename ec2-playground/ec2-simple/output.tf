output "security_group_id" {
  description = "SG id"
  value       = aws_security_group.ec2_sg.id
}

output "asg_name" {
  description = "ASGName"
  value       = aws_autoscaling_group.ec2_asg.name
}
