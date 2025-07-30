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
      owner      = var.owner
      managed-by = "terraform"
    }
  }
}

module "vpc" {
  source = "../Modules/VPC"
}

module "alb" {
  source            = "../Modules/LB"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = [module.vpc.public_subnet_a, module.vpc.public_subnet_b]
  security_group_id = module.vpc.security_group_id
}

resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

module "asg" {
  source            = "../Modules/ASG"
  company_name      = "LexTechWorks"
  ami_id            = "ami-020cba7c55df1f615"
  instance_type     = "t2.micro"
  key_name          = aws_key_pair.key.key_name
  security_group_id = module.vpc.security_group_id
  subnet_ids        = module.vpc.public_subnet_ids
  user_data_script  = "${path.module}/script.sh"
  min_size          = 1
  max_size          = 2
  desired_capacity  = 1
  target_group_arn  = module.alb.target_group_arn
}

module "bastion" {
  source       = "../Modules/Bastion"
  company_name = "LexTechWorks"
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_a
  key_name     = aws_key_pair.key.key_name
  allowed_ip   = "SEU_IP/32" # Substitua pelo seu IP real
}