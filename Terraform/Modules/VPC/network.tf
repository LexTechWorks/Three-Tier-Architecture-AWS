# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-terraform"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "internet-gateway-terraform"
    Environment = var.environment
  }
}

# Subnet Pública (Bastion)
resource "aws_subnet" "public_subnet_bastion" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.bastion_subnet_cidr
  availability_zone       = var.availability_zones["a"]
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-bastion"
    Environment = var.environment
    Tier        = "public"
  }
}

# Subnets Privadas (Application Tier)
resource "aws_subnet" "private_subnet_app_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.app_subnet_cidrs["a"]
  availability_zone       = var.availability_zones["a"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "private-subnet-app-a"
    Environment = var.environment
    Tier        = "application"
  }
}

resource "aws_subnet" "private_subnet_app_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.app_subnet_cidrs["b"]
  availability_zone       = var.availability_zones["b"]
  map_public_ip_on_launch = false

  tags = {
    Name        = "private-subnet-app-b"
    Environment = var.environment
    Tier        = "application"
  }
}

# Subnets privadas para banco de dados (Tier 3)
resource "aws_subnet" "private_subnet_db_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zones["a"]

  tags = {
    Name        = "private-subnet-db-a"
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_subnet" "private_subnet_db_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.availability_zones["b"]

  tags = {
    Name        = "private-subnet-db-b"
    Environment = var.environment
    Tier        = "database"
  }
}

# NAT Gateway e EIP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_bastion.id

  tags = {
    Name        = "nat-gateway"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

# Route Tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "public-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "private-route-table"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "rta_bastion" {
  subnet_id      = aws_subnet.public_subnet_bastion.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_private_app_a" {
  subnet_id      = aws_subnet.private_subnet_app_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_private_app_b" {
  subnet_id      = aws_subnet.private_subnet_app_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_private_db_a" {
  subnet_id      = aws_subnet.private_subnet_db_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_private_db_b" {
  subnet_id      = aws_subnet.private_subnet_db_b.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group
resource "aws_security_group" "security_group" {
  name        = "security-group-terraform"
  description = "Security group para controle de acesso"
  vpc_id      = aws_vpc.vpc.id

  # SSH apenas do IP permitido
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # HTTP apenas para ALB
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # HTTPS apenas para ALB
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Tráfego de saída restrito
  egress {
    description = "Trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "security-group-terraform"
    Environment = var.environment
  }
}

# Security Group para ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group para Application Load Balancer"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "alb-security-group"
    Environment = var.environment
  }
}

# NACL para subnets públicas
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public_subnet_bastion.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.allowed_ssh_cidr
    from_port  = 22
    to_port    = 22
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "public-nacl"
    Environment = var.environment
  }
}

#RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group para RDS"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "MySQL/Aurora"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.security_group.id]
  }

  tags = {
    Name        = "rds-security-group"
    Environment = var.environment
  }
}