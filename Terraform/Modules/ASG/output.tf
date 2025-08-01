output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "ARN do Auto Scaling Group"
  value       = aws_autoscaling_group.asg.arn
}

output "launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.lt.id
}
