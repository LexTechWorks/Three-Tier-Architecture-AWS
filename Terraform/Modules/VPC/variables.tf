variable "public_subnet_ids" {
  description = "Subnets públicas para Bastion e Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets privadas para instâncias EC2"
  type        = list(string)
}