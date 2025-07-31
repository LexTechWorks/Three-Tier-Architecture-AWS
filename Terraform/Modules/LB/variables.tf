variable "environment" {
  description = "Ambiente da infraestrutura (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "subnet_ids" {
  description = "Lista de subnets em AZs diferentes para o ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID para o ALB"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado SSL/TLS do ACM"
  type        = string
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}