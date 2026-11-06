resource "aws_iam_instance_profile" "ecs-asg-k6_profile" {
  name = "ecs-asg-k6_profile"
  role = aws_iam_role.ecs-asg-k6_role.name
  tags = {
    Name           = "ecs-asg-k6_profile"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "ecs-asg-nat-instance_profile" {
  name = "ecs-asg-nat-instance_profile"
  role = aws_iam_role.ecs-asg-nat-instance_role.name
  tags = {
    Name           = "ecs-asg-nat-instance_profile"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "ecs-asg-nodes_profile" {
  name = "ecs-asg-nodes_profile"
  role = aws_iam_role.ecs-asg-nodes_role.name
  tags = {
    Name           = "ecs-asg-nodes_profile"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "autoscaling_group_ecs-asg-nodes_st_ecs-asg-state_doc" {
  statement {
    sid       = "AllowEcsasgcluster"
    effect    = "Allow"
    actions   = ["ecs:DeregisterContainerInstance", "ecs:DiscoverPollEndpoint", "ecs:Poll", "ecs:RegisterContainerInstance", "ecs:StartTelemetrySession", "ecs:Submit*"]
    resources = [aws_ecs_cluster.ecs-asg-cluster.arn]
  }
}

resource "aws_iam_policy" "autoscaling_group_ecs-asg-nodes_st_ecs-asg-state" {
  name        = "autoscaling_group_ecs-asg-nodes_st_ecs-asg-state"
  description = "Access Policy for ecs-asg-nodes"
  policy      = data.aws_iam_policy_document.autoscaling_group_ecs-asg-nodes_st_ecs-asg-state_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state_doc" {
  statement {
    sid       = "AllowPullFromRepo"
    effect    = "Allow"
    actions   = ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    resources = [aws_ecr_repository.ecs-asg-hub-ecr.arn]
  }
  statement {
    sid       = "AllowEcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state" {
  name        = "ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state"
  description = "Access Policy for ecs-asg-hub (Role: execution)"
  policy      = data.aws_iam_policy_document.ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state_doc.json
}

resource "aws_iam_role" "ecs-asg-k6_role" {
  name = "ecs-asg-k6_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "ecs-asg-k6_role"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "ecs-asg-nat-instance_role" {
  name = "ecs-asg-nat-instance_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "ecs-asg-nat-instance_role"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "ecs-asg-nodes_role" {
  name = "ecs-asg-nodes_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "ecs-asg-nodes_role"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "execution_role_ecs_ecs-asg-hub" {
  name = "execution_role_ecs_ecs-asg-hub"
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
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "execution_role_ecs_ecs-asg-hub"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_ecs-asg-hub" {
  name = "task_role_ecs_ecs-asg-hub"
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
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "task_role_ecs_ecs-asg-hub"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "autoscaling_group_ecs-asg-nodes_st_ecs-asg-state_attach" {
  policy_arn = aws_iam_policy.autoscaling_group_ecs-asg-nodes_st_ecs-asg-state.arn
  role       = aws_iam_role.ecs-asg-nodes_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state_attach" {
  policy_arn = aws_iam_policy.ecs_task_definition_ecs-asg-hub_execution_st_ecs-asg-state.arn
  role       = aws_iam_role.execution_role_ecs_ecs-asg-hub.name
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonEC2ContainerServiceforEC2Role_to_ecs-asg-nodes_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs-asg-nodes_role.name
}
