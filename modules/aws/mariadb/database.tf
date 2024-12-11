resource "random_password" "database" {
  length = 20
  special = false
}

resource "aws_security_group" "database" {
  name        = var.prefix
  description = var.prefix
  vpc_id      = var.vpc_id
  tags = {
    Name = "Allow kubernetes access to database"
  }
}

resource "aws_security_group_rule" "database-i" {
  type              = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = var.allowed_subnets
  security_group_id = aws_security_group.database.id
}

resource "aws_db_instance" "database" {
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type         = "gp3"
  db_subnet_group_name = var.database_subnet_group
  engine               = "mariadb"
  engine_version       = "10.11.9"
  instance_class       = var.instance_class
  db_name                 = replace(var.prefix, "-", "")
  identifier           = var.prefix
  username             = "rdsroot"
  password             = random_password.database.result
  auto_minor_version_upgrade = false
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_retention_period = 0
  monitoring_interval = 0
  multi_az             = false
  apply_immediately    = true
  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  vpc_security_group_ids = [aws_security_group.database.id]
  lifecycle {
      ignore_changes = [ engine_version ]
  }
}

resource "aws_secretsmanager_secret" "database" {
  name = "${var.prefix}-database"
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id     = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    hostname              = aws_db_instance.database.address
    password          = random_password.database.result
    username              = "rdsroot"
  })
}

