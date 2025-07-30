variable "ami_id" {
  description = "AMI usada para o Bastion"
  type        = string
  default     = "ami-020cba7c55df1f615"
}

variable "instance_type" {
  description = "Tipo da instância Bastion"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = "aws-key"
}

variable "user_data_script" {
  description = "Script de inicialização"
  type        = string
  default     = "/script.sh"
}

variable "subnet_ids" {
  description = "Subnets públicas"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "IP permitido para acesso SSH (ex: 200.100.50.25/32)"
  type        = string
}