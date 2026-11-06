resource "aws_ecr_repository" "ecs-asg-hub-ecr" {
  name                 = "ecs-asg-hub-ecr"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name           = "ecs-asg-hub-ecr"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_capacity_provider" "asg-ec2-cp" {
  name = "asg-ec2-cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs-asg-nodes.arn
    managed_draining               = "ENABLED"
    managed_termination_protection = "DISABLED"
    managed_scaling {
      instance_warmup_period    = 60
      maximum_scaling_step_size = 10000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
  tags = {
    Name           = "asg-ec2-cp"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_cluster" "ecs-asg-cluster" {
  name = "ecs-asg-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    Name           = "ecs-asg-cluster"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecs_cluster_capacity_providers" "assoc_cp_to_ecs-asg-cluster" {
  cluster_name       = aws_ecs_cluster.ecs-asg-cluster.name
  capacity_providers = [aws_ecs_capacity_provider.asg-ec2-cp.name]
}

resource "aws_ecs_service" "ecs-asg-hub_service" {
  name                          = "ecs-asg-hub_service"
  availability_zone_rebalancing = "DISABLED"
  cluster                       = aws_ecs_cluster.ecs-asg-cluster.id
  desired_count                 = 1
  enable_ecs_managed_tags       = true
  force_delete                  = true
  iam_role                      = "/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  propagate_tags                = "TASK_DEFINITION"
  scheduling_strategy           = "REPLICA"
  task_definition               = "${aws_ecs_task_definition.ecs-asg-hub.family}:${aws_ecs_task_definition.ecs-asg-hub.revision}"
  capacity_provider_strategy {
    base              = 0
    capacity_provider = aws_ecs_capacity_provider.asg-ec2-cp.name
    weight            = 1
  }
  deployment_configuration {
    bake_time_in_minutes = "0"
    strategy             = "ROLLING"
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
  load_balancer {
    container_name   = "hub"
    container_port   = 8080
    target_group_arn = aws_lb_target_group.ecs-asg-tg-hub.arn
  }
  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }
  tags = {
    Name           = "ecs-asg-hub_service"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_lb_listener.ecs-asg-listener]
}

locals {
  container_def_ecs-asg-hub_hub = {
    name      = "hub"
    image     = "952133486861.dkr.ecr.us-west-2.amazonaws.com/ecs-asg-hub-ecr:latest"
    essential = true
    cpu       = 128
    memory    = 85
    portMappings = [
      {
        protocol      = "tcp"
        containerPort = 8080
      }
    ]
    environment = [
      {
        name  = "ACCOUNT"
        value = "952133486861"
      },
      {
        name  = "AWS_ECS_CAPACITY_PROVIDER_NAME_0"
        value = tostring(aws_ecs_capacity_provider.asg-ec2-cp.name)
      },
      {
        name  = "HUB_LOADTEST"
        value = "on"
      },
      {
        name  = "HUB_WORKERS"
        value = "1"
      },
      {
        name  = "NAME"
        value = "ecs-asg-hub"
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

resource "aws_ecs_task_definition" "ecs-asg-hub" {
  container_definitions    = jsonencode([local.container_def_ecs-asg-hub_hub])
  cpu                      = "128"
  execution_role_arn       = aws_iam_role.execution_role_ecs_ecs-asg-hub.arn
  family                   = "ecs-asg-hub"
  memory                   = "100"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.task_role_ecs_ecs-asg-hub.arn
  tags = {
    Name           = "ecs-asg-hub"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state_attach_execution_role_ecs_ecs-asg-hub]
}
