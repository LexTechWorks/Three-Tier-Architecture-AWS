output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.vpc.id
}

output "bastion_subnet_id" {
  description = "ID da subnet pública para Bastion"
  value       = aws_subnet.public_subnet_bastion.id
}

output "private_app_subnet_ids" {
  description = "IDs das subnets privadas para aplicação"
  value = [
    aws_subnet.private_subnet_app_a.id,
    aws_subnet.private_subnet_app_b.id
  ]
}

output "private_db_subnet_ids" {
  description = "IDs das subnets privadas para banco de dados"
  value = [
    aws_subnet.private_subnet_db_a.id,
    aws_subnet.private_subnet_db_b.id
  ]
}

output "alb_security_group_id" {
  description = "ID do security group do ALB"
  value       = aws_security_group.alb_sg.id
}

output "nat_gateway_id" {
  description = "ID do NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "app_security_group_id" {
  description = "ID do SG da aplicação"
  value       = aws_security_group.app_sg.id
}

output "bastion_security_group_id" {
  description = "ID do SG do Bastion"
  value       = aws_security_group.bastion_sg.id
}