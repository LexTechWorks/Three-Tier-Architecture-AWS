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

# Outputs do Bastion
output "bastion_asg_name" {
  description = "Nome do Auto Scaling Group do Bastion"
  value       = module.bastion_asg.asg_name
}

# Outputs da Aplicação
output "app_asg_name" {
  description = "Nome do Auto Scaling Group da Aplicação"
  value       = module.app_asg.asg_name
}

## Outputs do RDS
#output "database_endpoint" {
#  description = "Endpoint de conexão do RDS"
#  value       = module.rds.db_instance_endpoint
#  sensitive   = false
#}

#output "database_subnet_group" {
#  description = "Nome do grupo de subnets do RDS"
#  value       = module.rds.db_subnet_group_name
#}

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