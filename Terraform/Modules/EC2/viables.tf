variable "subnet_ids" {
  description = "Lista de subnets em AZs diferentes para as instâncias EC2"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}

variable "public_key_path" {
  description = "Caminho do arquivo .pub para criar a key pair"
  type        = string
}

variable "user_data_script" {
  description = "Script de inicialização para instalar o nginx"
  type        = string
}

variable "instance_count" {
  description = "Quantidade de instâncias EC2"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "ID da VPC onde o ALB será criado"
  type        = string
}