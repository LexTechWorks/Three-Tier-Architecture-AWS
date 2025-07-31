output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "target_group_arn" {
  description = "ARN do Target Group"
  value       = aws_lb_target_group.tg.arn
}

output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_zone_id" {
  description = "Route53 Zone ID do ALB"
  value       = aws_lb.alb.zone_id
}

output "dns_name" {
  description = "DNS público do Load Balancer"
  value       = aws_lb.alb.dns_name
}