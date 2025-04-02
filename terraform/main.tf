provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "nequi-db"
  engine                  = "postgres"
  engine_version          = "17.2"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  publicly_accessible     = true
  skip_final_snapshot     = true
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
}

resource "aws_ecr_repository" "app_repo" {
  name = "nequi-franquicias-repo"
}

resource "aws_ecs_cluster" "app_cluster" {
  name = "nequi-franquicias-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "nequi-franquicias-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"

  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = aws_ecr_repository.app_repo.repository_url
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "nequi-franquicias-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.allow_all.id]
    assign_public_ip = true
  }
}

output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
