resource "aws_ecr_repository" "ecs-asg-hub-ecr" {
  name                 = "ecs-asg-hub-ecr"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
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
  name                    = "ecs-asg-hub_service"
  cluster                 = aws_ecs_cluster.ecs-asg-cluster.id
  desired_count           = 1
  enable_ecs_managed_tags = true
  force_delete            = true
  propagate_tags          = "TASK_DEFINITION"
  scheduling_strategy     = "REPLICA"
  task_definition         = "${aws_ecs_task_definition.ecs-asg-hub.family}:${aws_ecs_task_definition.ecs-asg-hub.revision}"
  capacity_provider_strategy {
    base              = 0
    capacity_provider = aws_ecs_capacity_provider.asg-ec2-cp.name
    weight            = 1
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
  depends_on = [aws_lb_listener.ecs-asg-listener, terraform_data.seed_ecs-asg-hub-ecr]
}

locals {
  container_def_ecs-asg-hub_hub = {
    name      = "hub"
    image     = "${aws_ecr_repository.ecs-asg-hub-ecr.repository_url}:latest"
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
        value = tostring(data.aws_region.current.region)
      },
      {
        name  = "ACCOUNT"
        value = tostring(data.aws_caller_identity.current.account_id)
      },
      {
        name  = "AWS_ECS_CAPACITY_PROVIDER_NAME_0"
        value = "asg-ec2-cp"
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
  depends_on = [aws_iam_role_policy_attachment.ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state_attach]
}
