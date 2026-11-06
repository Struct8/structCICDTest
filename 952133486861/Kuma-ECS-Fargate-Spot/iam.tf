resource "aws_iam_role" "execution_role_ecs_kuma" {
  name                  = "execution_role_ecs_kuma"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "execution_role_ecs_kuma"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_kuma" {
  name                  = "task_role_ecs_kuma"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "task_role_ecs_kuma"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}
