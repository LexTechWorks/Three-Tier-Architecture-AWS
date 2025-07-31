variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Responsável pela infraestrutura"
  type        = string
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = "aws-key"
}

variable "public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
}

variable "bastion_ami_id" {
  description = "AMI ID para Bastion"
  type        = string
  default     = "ami-020cba7c55df1f615"
}

variable "bastion_instance_type" {
  description = "Tipo de instância para Bastion"
  type        = string
  default     = "t2.micro"
}

variable "app_ami_id" {
  description = "AMI ID para Application"
  type        = string
  default     = "ami-020cba7c55df1f615"
}

variable "app_instance_type" {
  description = "Tipo de instância para Application"
  type        = string
  default     = "t2.micro"
}

variable "app_min_size" {
  description = "Número mínimo de instâncias da aplicação"
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Número máximo de instâncias da aplicação"
  type        = number
  default     = 4
}

variable "app_desired_capacity" {
  description = "Número desejado de instâncias da aplicação"
  type        = number
  default     = 2
}

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para acesso SSH ao Bastion"
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado SSL/TLS para o ALB"
  type        = string
  default     = "arn:aws:acm:us-east-1:833371734412:certificate/ad4ebb30-7838-4814-b942-6a4d5a6641e5"
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade para as subnets"
  type        = map(string)
  default = {
    a = "us-east-1a"
    b = "us-east-1b"
  }
}

#variable "private_db_subnet_ids" {
#  description = "IDs das subnets privadas para o banco de dados"
#  type        = list(string)
#}