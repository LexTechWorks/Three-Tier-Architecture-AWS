variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs das subnets privadas para o banco de dados"
  type        = list(string)
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Username para o banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Senha para o banco de dados"
  type        = string
  sensitive   = true
}

variable "db_security_group_id" {
  description = "ID do security group para o RDS"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para os recursos do RDS"
  type        = map(string)
  default     = {}
}