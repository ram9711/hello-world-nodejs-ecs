provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "example" {
  name = "example"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "example"
      image     = "YOUR_DOCKER_IMAGE_URL"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        },
      ]
    },
  ])
}

resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    subnets         = ["YOUR_SUBNET_ID"]
    security_groups = ["YOUR_SECURITY_GROUP_ID"]
  }
}
