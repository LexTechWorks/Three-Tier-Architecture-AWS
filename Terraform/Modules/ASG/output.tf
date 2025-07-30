output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}