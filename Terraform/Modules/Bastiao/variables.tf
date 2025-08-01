variable "bastion_ami_id" {
  description = "AMI ID para o Bastion Host"
  type        = string
  default = "ami-020cba7c55df1f615"
}

variable "bastion_instance_type" {
  description = "Tipo de instância para o Bastion Host"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default = "aws-key"
}

variable "subnet_id" {
  description = "ID da subnet pública para o Bastion"
  type        = string
}

variable "security_group_id" {
  description = "ID do Security Group do Bastion"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default = "prod"
}

variable "user_data_script" {
  description = "Caminho para o script de inicialização"
  type        = string
}