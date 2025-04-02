# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnets en diferentes AZs
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
}

# Grupo de seguridad
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Accesible desde cualquier lugar
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Grupo de subredes para RDS
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier              = "nequi-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"  # Gratis en AWS Free Tier
  allocated_storage      = 20
  username              = "admin"
  password              = "supersecurepassword"
  publicly_accessible   = true
  skip_final_snapshot   = true
  db_subnet_group_name  = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
}

# Repositorio ECR
resource "aws_ecr_repository" "app_repo" {
  name = "nequi-franquicias-repo"

  lifecycle {
    ignore_changes = [name]
  }
}

# Cluster ECS
resource "aws_ecs_cluster" "app_cluster" {
  name = "nequi-cluster"
}

# Definición de tarea en ECS
resource "aws_ecs_task_definition" "app_task" {
  family                   = "nequi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name  = "app-container"
      image = aws_ecr_repository.app_repo.repository_url
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
    }
  ])
}

# Salidas
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
