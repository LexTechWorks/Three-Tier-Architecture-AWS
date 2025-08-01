resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [var.security_group_id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    encrypted            = true
    delete_on_termination = true
  }

  user_data_base64 = base64encode(templatefile(var.user_data_script, {
    ENVIRONMENT = var.environment
  }))

  tags = {
    Name        = "${var.environment}-bastion"
    Environment = var.environment
    ManagedBy   = "terraform"
    Role        = "bastion"
    Tier        = "Web Tier/Bastion"
    SSHUser     = "ubuntu"
  }
}