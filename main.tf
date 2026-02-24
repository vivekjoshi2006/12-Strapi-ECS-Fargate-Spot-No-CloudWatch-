provider "aws" {
  region = "us-east-1"
}

# NETWORKING (Default VPC)

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "az1" {
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "az2" {
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg-vivek-v12"
  description = "Allow Strapi access on port 1337"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS CLUSTER (SPOT ONLY)

resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-vivek-v12"
}

resource "aws_ecs_cluster_capacity_providers" "strapi_spot" {
  cluster_name       = aws_ecs_cluster.strapi_cluster.name
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

# TASK DEFINITION

resource "aws_ecs_task_definition" "strapi" {
  family                   = "strapi-task-vivek"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = "arn:aws:iam::811738710312:role/ecsTaskExecutionRole"
  task_role_arn      = "arn:aws:iam::811738710312:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${var.ecr_repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "DATABASE_HOST", value = var.db_host },
        { name = "DATABASE_NAME", value = var.db_name },
        { name = "DATABASE_USERNAME", value = var.db_user },
        { name = "DATABASE_PASSWORD", value = var.db_password }
      ]
    }
  ])
}

# ECS SERVICE (FARGATE SPOT)

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-vivek"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1

  platform_version = "LATEST"

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }

  network_configuration {
    subnets          = [
      aws_default_subnet.az1.id,
      aws_default_subnet.az2.id
    ]
    security_groups  = [aws_security_group.strapi_sg.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_ecs_cluster_capacity_providers.strapi_spot
  ]
}