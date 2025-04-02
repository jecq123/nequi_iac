resource "aws_db_instance" "postgres" {
  identifier              = "my-free-db"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  skip_final_snapshot    = true
  backup_retention_period = 0
  parameter_group_name  = "grupo1"
  username              = var.db_username
  password              = var.db_password
  db_name               = var.db_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Accesible públicamente (NO recomendado en producción)
  }
}
