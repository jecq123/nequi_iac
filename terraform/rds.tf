resource "aws_db_parameter_group" "postgres_group" {
  name   = "grupo1"
  family = "postgres17"
}

resource "aws_db_instance" "postgres" {
  identifier              = "nequi"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  skip_final_snapshot    = true
  backup_retention_period = 0
  parameter_group_name  = aws_db_parameter_group.postgres_group.name
  username              = var.db_username
  password              = var.db_password
  db_name               = var.db_name
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
}

output "db_endpoint" {
  value = aws_db_instance.postgres.address
}
