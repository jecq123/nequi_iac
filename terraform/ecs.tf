resource "aws_ecs_cluster" "app_cluster" {
  name = "nequi-franquicias-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "nequi-franquicias-task"
  container_definitions    = jsonencode([
    {
      name      = "app"
      image     = var.ecr_repo_url
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
  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}
