resource "aws_iam_role" "execution_role_ecs_kuma" {
  name = "execution_role_ecs_kuma"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags = {
    Name           = "execution_role_ecs_kuma"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_kuma" {
  name = "task_role_ecs_kuma"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
})
  tags = {
    Name           = "task_role_ecs_kuma"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}
