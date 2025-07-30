variable "company_name" {
  description = "Nome da empresa ou projeto"
  type        = string
  default     = "Lextechworks"
}

variable "ami_id" {
  description = "ID da imagem AMI"
  type        = string
  default     = "ami-020cba7c55df1f615"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = "aws-key"
}

variable "security_group_id" {
  description = "ID do Security Group"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets públicas"
  type        = list(string)
}

variable "user_data_script" {
  description = "Caminho para o script de inicialização"
  type        = string
  default     = "/script.sh"
}

variable "min_size" {
  description = "Mínimo de instâncias"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Máximo de instâncias"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Capacidade inicial"
  type        = number
}

variable "target_group_arn" {
  description = "ARN do Target Group do ALB"
  type        = string
}