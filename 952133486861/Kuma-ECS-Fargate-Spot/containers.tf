resource "aws_ecs_cluster" "kuma-cluster" {
  name = "kuma-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name           = "kuma-cluster"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_cluster_capacity_providers" "assoc_cp_to_kuma-cluster" {
  cluster_name       = aws_ecs_cluster.kuma-cluster.name
  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_ecs_service" "kuma_service" {
  name                          = "kuma_service"
  availability_zone_rebalancing = "ENABLED"
  cluster                       = aws_ecs_cluster.kuma-cluster.id
  desired_count                 = 1
  enable_ecs_managed_tags       = true
  force_delete                  = true
  iam_role                      = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  platform_version              = "LATEST"
  propagate_tags                = "TASK_DEFINITION"
  scheduling_strategy           = "REPLICA"
  task_definition               = "${aws_ecs_task_definition.kuma.family}:${aws_ecs_task_definition.kuma.revision}"
  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
  deployment_configuration {
    bake_time_in_minutes = "0"
    strategy             = "ROLLING"
  }
  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_task_definition_kuma_group.id]
    subnets          = [aws_subnet.public.id]
  }
  tags = {
    Name           = "kuma_service"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

locals {
  container_def_kuma_kuma_1 = {
    name      = "kuma"
    image     = "docker.io/louislam/uptime-kuma:1"
    essential = true
    cpu       = 128
    memory    = 256
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = 3001
        hostPort      = 3001
      }
    ]
    environment = [
      {
        name  = "ACCOUNT"
        value = "952133486861"
      },
      {
        name  = "NAME"
        value = "kuma"
      },
      {
        name  = "REGION"
        value = "us-west-2"
      }
    ]
    mountPoints            = []
    systemControls         = []
    volumesFrom            = []
    privileged             = false
    readonlyRootFilesystem = false
  }
}

resource "aws_ecs_task_definition" "kuma" {
  container_definitions    = jsonencode([local.container_def_kuma_kuma_1])
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.execution_role_ecs_kuma.arn
  family                   = "uptime-kuma"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role_ecs_kuma.arn
  tags = {
    Name           = "kuma"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}
