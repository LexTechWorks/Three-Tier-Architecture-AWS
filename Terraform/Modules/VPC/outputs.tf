output "security_group_id" {
  description = "ID da security group criada na AWS"
  value       = aws_security_group.security_group.id
}

#output "vm_ips" {
# value = module.ec2.vm_public_ip
#}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_a" {
  description = "ID da subnet pública na AZ us-east-1a"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_b" {
  description = "ID da subnet pública na AZ us-east-1b"
  value       = aws_subnet.public_subnet_b.id
}

output "private_subnet_ids" {
  description = "Lista de subnets privadas"
  value = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_b.id
  ]
}
