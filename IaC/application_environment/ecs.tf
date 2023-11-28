resource "aws_ecr_repository" "this" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.app_name
  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "flask-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = aws_ecr_repository.this.repository_url

      portMappings = [
        {
          containerPort = 8888,
          hostPort      = 8888,
        },
      ]

      essential = true
    },
  ])
}

resource "aws_ecs_service" "this" {
  name                               = "${var.app_name}-service"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.this.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  enable_ecs_managed_tags            = true


  network_configuration {
    security_groups = [
    aws_security_group.ecs_sg.id]
    subnets = aws_subnet.public_subnets.*.id
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.app_name
    container_port   = 8888
    target_group_arn = aws_alb_target_group.this.id
  }

  depends_on = [
    aws_alb_listener.this
  ]

  lifecycle {
    ignore_changes = [
    task_definition, desired_count]
  }
}