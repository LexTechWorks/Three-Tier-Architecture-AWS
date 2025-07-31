variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bastion_subnet_cidr" {
  description = "CIDR para subnet pública do Bastion"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_subnet_cidrs" {
  description = "CIDRs para subnets privadas da aplicação"
  type        = map(string)
  default     = {
    a = "10.0.2.0/24"
    b = "10.0.3.0/24"
  }
}

variable "db_subnet_cidrs" {
  description = "CIDRs para subnets privadas do banco de dados"
  type        = map(string)
  default     = {
    a = "10.0.4.0/24"
    b = "10.0.5.0/24"
  }
}

variable "availability_zones" {
  description = "Availability zones para criar as subnets"
  type        = map(string)
  default     = {
    a = "us-east-1a"
    b = "us-east-1b"
  }
}

variable "environment" {
  description = "Ambiente (ex: dev, prod, staging)"
  type        = string
  default     = "dev"
}

variable "allowed_ssh_cidr" {
  description = "CIDR permitido para acesso SSH"
  type        = string
}