resource "aws_ecr_repository" "hub-image" {
  name                 = "hub-image"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name           = "hub-image"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_cluster" "hub-cluster" {
  name = "hub-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name           = "hub-cluster"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_cluster_capacity_providers" "assoc_cp_to_hub-cluster" {
  cluster_name       = aws_ecs_cluster.hub-cluster.name
  capacity_providers = ["FARGATE_SPOT"]
}

resource "aws_ecs_service" "hub_service" {
  name                          = "hub_service"
  availability_zone_rebalancing = "ENABLED"
  cluster                       = aws_ecs_cluster.hub-cluster.id
  desired_count                 = 1
  enable_ecs_managed_tags       = true
  force_delete                  = true
  iam_role                      = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  platform_version              = "LATEST"
  propagate_tags                = "TASK_DEFINITION"
  scheduling_strategy           = "REPLICA"
  task_definition               = "${aws_ecs_task_definition.hub.family}:${aws_ecs_task_definition.hub.revision}"
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
    security_groups  = [aws_security_group.ecs_task_definition_hub_group.id]
    subnets          = [aws_subnet.hub-public-a.id]
  }
  tags = {
    Name           = "hub_service"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

locals {
  container_def_hub_hub_1 = {
    name      = "hub"
    image     = "952133486861.dkr.ecr.us-west-2.amazonaws.com/hub-image:latest"
    essential = true
    cpu       = 128
    memory    = 256
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = 8080
        hostPort      = 8080
      }
    ]
    environment = [
      {
        name  = "ACCOUNT"
        value = "952133486861"
      },
      {
        name  = "AWS_DYNAMODB_TABLE_NAME_0"
        value = "hub-out"
      },
      {
        name  = "AWS_LAMBDA_FUNCTION_NAME_0"
        value = "hub-fn"
      },
      {
        name  = "AWS_S3_BUCKET_NAME_0"
        value = "hub-demo-952133486861-us-west-2-an"
      },
      {
        name  = "AWS_SECRETSMANAGER_SECRET_NAME_0"
        value = "hub-secret"
      },
      {
        name  = "AWS_SNS_TOPIC_NAME_0"
        value = "hub-topic"
      },
      {
        name  = "AWS_SQS_QUEUE_NAME_0"
        value = "hub-in"
      },
      {
        name  = "AWS_SSM_PARAMETER_NAME_0"
        value = "hub-param"
      },
      {
        name  = "HUB_POLL"
        value = "hub-in"
      },
      {
        name  = "NAME"
        value = "hub"
      },
      {
        name  = "REGION"
        value = "us-west-2"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.hub-logs.name
        awslogs-region        = "us-west-2"
        awslogs-stream-prefix = "hub"
      }
    }
    mountPoints            = []
    systemControls         = []
    volumesFrom            = []
    privileged             = false
    readonlyRootFilesystem = false
  }
}

resource "aws_ecs_task_definition" "hub" {
  container_definitions    = jsonencode([local.container_def_hub_hub_1])
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.execution_role_ecs_hub.arn
  family                   = "hub"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role_ecs_hub.arn
  tags = {
    Name           = "hub"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_definition_hub_st_hub-state_attach, aws_iam_role_policy_attachment.ecs_task_definition_hub_execution_st_hub-state_attach]
}
