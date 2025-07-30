output "bastion_nlb_dns" {
  description = "DNS público do Bastião via NLB"
  value       = aws_lb.bastion_nlb.dns_name
}

output "bastion_asg_name" {
  description = "Nome do Auto Scaling Group do Bastião"
  value       = aws_autoscaling_group.bastion_asg.name
}