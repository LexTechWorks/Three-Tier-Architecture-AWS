# Outputs do Load Balancer
output "alb_dns_name" {
  description = "DNS name do Application Load Balancer"
  value       = module.alb.dns_name
}

# Outputs da VPC
output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

# Output do Bastion
output "bastion_public_ip" {
  description = "IP público do Bastion Host"
  value       = module.bastion.public_ip
}

# Outputs da Aplicação
output "app_asg_name" {
  description = "Nome do Auto Scaling Group da Aplicação"
  value       = module.app_asg.asg_name
}

# Outputs de Rede
output "private_app_subnet_ids" {
  description = "IDs das subnets privadas da aplicação"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs das subnets privadas do banco de dados"
  value       = module.vpc.private_db_subnet_ids
}

output "bastion_subnet_id" {
  description = "ID da subnet pública do Bastion"
  value       = module.vpc.bastion_subnet_id
}