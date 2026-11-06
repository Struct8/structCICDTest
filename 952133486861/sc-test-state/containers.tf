resource "aws_ecs_cluster" "sc-test-cluster1" {
  name = "sc-test-cluster1"
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.sc-test-ns.arn
  }
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name           = "sc-test-cluster1"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_service" "sc-client_service" {
  name                          = "sc-client_service"
  availability_zone_rebalancing = "ENABLED"
  cluster                       = aws_ecs_cluster.sc-test-cluster1.id
  desired_count                 = 1
  enable_ecs_managed_tags       = true
  force_delete                  = true
  iam_role                      = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  launch_type                   = "FARGATE"
  platform_version              = "LATEST"
  propagate_tags                = "TASK_DEFINITION"
  scheduling_strategy           = "REPLICA"
  task_definition               = "${aws_ecs_task_definition.sc-client.family}:${aws_ecs_task_definition.sc-client.revision}"
  deployment_configuration {
    bake_time_in_minutes = "0"
    strategy             = "ROLLING"
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_task_definition_sc-client_group.id]
    subnets          = [aws_subnet.sc-test-private-a.id]
  }
  service_connect_configuration {
    enabled   = true
    namespace = "arn:aws:servicediscovery:us-west-2:952133486861:namespace/ns-bgxttzyd6jndnccb"
  }
  tags = {
    Name           = "sc-client_service"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_service" "sc-server_service" {
  name                          = "sc-server_service"
  availability_zone_rebalancing = "ENABLED"
  cluster                       = aws_ecs_cluster.sc-test-cluster1.id
  desired_count                 = 3
  enable_ecs_managed_tags       = true
  force_delete                  = true
  iam_role                      = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  launch_type                   = "FARGATE"
  platform_version              = "LATEST"
  propagate_tags                = "TASK_DEFINITION"
  scheduling_strategy           = "REPLICA"
  task_definition               = "${aws_ecs_task_definition.sc-server.family}:${aws_ecs_task_definition.sc-server.revision}"
  deployment_configuration {
    bake_time_in_minutes = "0"
    strategy             = "ROLLING"
  }
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_task_definition_sc-server_group.id]
    subnets          = [aws_subnet.sc-test-private-a.id]
  }
  service_connect_configuration {
    enabled   = true
    namespace = "arn:aws:servicediscovery:us-west-2:952133486861:namespace/ns-bgxttzyd6jndnccb"
    service {
      discovery_name        = "server"
      port_name             = "server-80"
      ingress_port_override = 0
      client_alias {
        dns_name = "server"
        port     = 80
      }
    }
  }
  tags = {
    Name           = "sc-server_service"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

locals {
  container_def_sc-client_client = {
    name      = "client"
    image     = "curlimages/curl:latest"
    essential = true
    cpu       = 128
    memory    = 256
    environment = [
      {
        name  = "ACCOUNT"
        value = "952133486861"
      },
      {
        name  = "AWS_ECS_TASK_DEFINITION_NAME_0"
        value = "sc-server"
      },
      {
        name  = "NAME"
        value = "sc-client"
      },
      {
        name  = "REGION"
        value = "us-west-2"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.client-test-logs.name
        awslogs-region        = "us-west-2"
        awslogs-stream-prefix = "client"
      }
    }
    mountPoints            = []
    systemControls         = []
    volumesFrom            = []
    command                = ["sh", "-c", "sleep 30; while true; do echo \"--- $(date +%T) ---\"; curl -sS --max-time 5 http://server:80/ 2>&1 | grep -Ei 'Hostname|curl:|resolve' || echo 'NO-RESPONSE'; sleep 4; done"]
    privileged             = false
    readonlyRootFilesystem = false
  }
}

resource "aws_ecs_task_definition" "sc-client" {
  container_definitions    = jsonencode([local.container_def_sc-client_client])
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.execution_role_ecs_sc-client.arn
  family                   = "sc-client"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role_ecs_sc-client.arn
  tags = {
    Name           = "sc-client"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_definition_sc-client_execution_st_sc-test-state_attach]
}

locals {
  container_def_sc-server_server = {
    name      = "server"
    image     = "traefik/whoami:latest"
    essential = true
    cpu       = 128
    memory    = 256
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = 80
        hostPort      = 80
        name          = "server-80"
      }
    ]
    environment = [
      {
        name  = "ACCOUNT"
        value = "952133486861"
      },
      {
        name  = "NAME"
        value = "sc-server"
      },
      {
        name  = "REGION"
        value = "us-west-2"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.server-test-logs.name
        awslogs-region        = "us-west-2"
        awslogs-stream-prefix = "server"
      }
    }
    mountPoints            = []
    systemControls         = []
    volumesFrom            = []
    privileged             = false
    readonlyRootFilesystem = false
  }
}

resource "aws_ecs_task_definition" "sc-server" {
  container_definitions    = jsonencode([local.container_def_sc-server_server])
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.execution_role_ecs_sc-server.arn
  family                   = "sc-server"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.task_role_ecs_sc-server.arn
  tags = {
    Name           = "sc-server"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_definition_sc-server_execution_st_sc-test-state_attach]
}
