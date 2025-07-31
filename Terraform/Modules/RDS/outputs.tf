output "db_instance_endpoint" {
  description = "Endpoint de conexão do banco de dados"
  value       = aws_db_instance.database.endpoint
}

output "db_instance_id" {
  description = "ID da instância do banco de dados"
  value       = aws_db_instance.database.id
}

output "db_subnet_group_name" {
  description = "Nome do grupo de subnets do banco de dados"
  value       = aws_db_subnet_group.db_subnet_group.name
}