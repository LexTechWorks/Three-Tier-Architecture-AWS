#É importante ir no main.tf e declarar a bucket que será feito o backend

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Dono dos recursos"
  type        = string
  default     = "Gabriel"
}

variable "key_name" {
  description = "Nome da chave SSH registrada na AWS"
  type        = string
  default     = "aws-key"
}

variable "public_key_path" {
  description = "Caminho do arquivo de chave pública (.pub)"
  type        = string
  default     = "C:/Users/Lesley/Documents/Curso-gabriel/AWS-Keys/key/aws-key.pub"
}