resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids  # Usar subnets específicas para DB

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_db_instance" "database" {
  identifier        = "${var.environment}-database"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Garantir que o RDS use o grupo de subnets correto
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.db_security_group_id]

  # Configurações adicionais de segurança
  storage_encrypted     = true
  publicly_accessible  = false  # Garante que o RDS não seja acessível publicamente

  backup_retention_period = 7
  multi_az               = var.environment == "prod" ? true : false
  skip_final_snapshot    = true

  tags = {
    Name        = "${var.environment}-database"
    Environment = var.environment
    Tier        = "database"
  }
}