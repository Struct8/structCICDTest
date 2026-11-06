resource "aws_iam_instance_profile" "sc-test-nat_profile" {
  name = "sc-test-nat_profile"
  role = aws_iam_role.sc-test-nat_role.name
  tags = {
    Name           = "sc-test-nat_profile"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "ecs_task_definition_sc-client_execution_st_sc-test-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.client-test-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_sc-client_execution_st_sc-test-state" {
  name        = "ecs_task_definition_sc-client_execution_st_sc-test-state"
  description = "Access Policy for sc-client (Role: execution)"
  policy      = data.aws_iam_policy_document.ecs_task_definition_sc-client_execution_st_sc-test-state_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_sc-server_execution_st_sc-test-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.server-test-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_sc-server_execution_st_sc-test-state" {
  name        = "ecs_task_definition_sc-server_execution_st_sc-test-state"
  description = "Access Policy for sc-server (Role: execution)"
  policy      = data.aws_iam_policy_document.ecs_task_definition_sc-server_execution_st_sc-test-state_doc.json
}

resource "aws_iam_role" "execution_role_ecs_sc-client" {
  name = "execution_role_ecs_sc-client"
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
    Name           = "execution_role_ecs_sc-client"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "execution_role_ecs_sc-server" {
  name = "execution_role_ecs_sc-server"
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
    Name           = "execution_role_ecs_sc-server"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "sc-test-nat_role" {
  name = "sc-test-nat_role"
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
    Name           = "sc-test-nat_role"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_sc-client" {
  name = "task_role_ecs_sc-client"
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
    Name           = "task_role_ecs_sc-client"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_sc-server" {
  name = "task_role_ecs_sc-server"
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
    Name           = "task_role_ecs_sc-server"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_sc-client_execution_st_sc-test-state_attach" {
  policy_arn = aws_iam_policy.ecs_task_definition_sc-client_execution_st_sc-test-state.arn
  role       = aws_iam_role.execution_role_ecs_sc-client.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_sc-server_execution_st_sc-test-state_attach" {
  policy_arn = aws_iam_policy.ecs_task_definition_sc-server_execution_st_sc-test-state.arn
  role       = aws_iam_role.execution_role_ecs_sc-server.name
}
