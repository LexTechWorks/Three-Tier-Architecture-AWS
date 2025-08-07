terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.2.0"
    }
  }

  backend "s3" {
    bucket = "lextechworks"
    key    = "aws-env/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      owner       = var.owner
      environment = var.environment
      managed-by  = "Terraform"
    }
  }
}

# Módulo VPC
module "vpc" {
  source             = "../Modules/VPC"
  vpc_cidr           = var.vpc_cidr
  allowed_ssh_cidr   = var.allowed_ssh_cidr
  environment        = var.environment
  availability_zones = var.availability_zones
}

# Módulo Load Balancer
module "alb" {
  source            = "../Modules/LB"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.vpc.alb_security_group_id
  certificate_arn   = var.certificate_arn
  environment       = var.environment
}

# Chave SSH para acesso às instâncias
resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Name        = "${var.environment}-key"
    Environment = var.environment
  }
}

module "bastion" {
  source                = "../Modules/Bastiao"
  bastion_ami_id        = var.bastion_ami_id
  bastion_instance_type = var.bastion_instance_type
  key_name              = aws_key_pair.key.key_name
  subnet_id             = module.vpc.bastion_subnet_id
  security_group_id     = module.vpc.bastion_security_group_id
  environment           = var.environment
  user_data_script      = "${path.module}/scripts/bastion_setup.sh"
}

module "app_asg" {
  source            = "../Modules/ASG"
  name_prefix       = "app"
  environment       = var.environment
  ami_id            = var.app_ami_id
  instance_type     = var.app_instance_type
  key_name          = aws_key_pair.key.key_name
  security_group_id = module.vpc.app_security_group_id
  subnet_ids        = module.vpc.private_app_subnet_ids
  min_size          = var.app_min_size
  max_size          = var.app_max_size
  desired_capacity  = var.app_desired_capacity
  target_group_arn  = module.alb.target_group_arn
  root_volume_size  = 10
  tags = {
    Type              = "application"
    Role              = "application"
    Tier              = "application"
    Project           = "ansible-integration"
    AnsibleManaged    = "true"
  }
}

module "route53" {
  source       = "../Modules/Route53"
  environment  = var.environment
  domain_name  = var.domain_name
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id

  depends_on = [module.alb]
}