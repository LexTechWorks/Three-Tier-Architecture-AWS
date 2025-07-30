output "vm_public_ip" {
  value = [for instance in aws_instance.vm : instance.public_ip]
}

output "vm_private_ip" {
  value = [for instance in aws_instance.vm : instance.private_ip]
}

output "instance_ids" {
  value = [for instance in aws_instance.vm : instance.id]
}