variable "subnet_ids" {
  description = "Lista de subnets em AZs diferentes para as instâncias EC2"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}

variable "ec2_instance_ids" {
  description = "Lista de IDs das instâncias EC2 para o Target Group (opcional)"
  type        = list(string)
  default     = []
}

output "dns_name" {
  description = "DNS do Load Balancer"
  value       = aws_lb.alb.dns_name
}