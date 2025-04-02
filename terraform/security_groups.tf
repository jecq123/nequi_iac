resource "aws_security_group" "db_sg" {
  name_prefix = "db-security-group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name_prefix = "ecs-security-group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}
