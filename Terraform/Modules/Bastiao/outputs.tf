output "public_ip" {
  description = "IP público da instância Bastion"
  value       = aws_instance.bastion.public_ip
}

output "private_ip" {
  description = "IP privado da instância Bastion"
  value       = aws_instance.bastion.private_ip
}

output "instance_id" {
  description = "ID da instância Bastion"
  value       = aws_instance.bastion.id
}

output "security_group_id" {
  description = "ID do Security Group do Bastion"
  value       = var.security_group_id
}