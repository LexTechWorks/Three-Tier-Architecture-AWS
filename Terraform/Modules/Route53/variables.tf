variable "domain_name" {
  description = "Nome do domínio para o Route 53"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS Name do ALB para o registro A"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID do ALB para o registro A"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}
