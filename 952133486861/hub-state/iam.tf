data "aws_iam_policy_document" "ecs_task_definition_hub_execution_st_hub-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.hub-logs.arn}:*"]
  }
  statement {
    sid       = "AllowPullFromRepo"
    effect    = "Allow"
    actions   = ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
    resources = [aws_ecr_repository.hub-image.arn]
  }
  statement {
    sid       = "AllowEcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_definition_hub_execution_st_hub-state" {
  name        = "ecs_task_definition_hub_execution_st_hub-state"
  description = "Access Policy for hub (Role: execution)"
  policy      = data.aws_iam_policy_document.ecs_task_definition_hub_execution_st_hub-state_doc.json
}

data "aws_iam_policy_document" "ecs_task_definition_hub_st_hub-state_doc" {
  statement {
    sid       = "AllowDynamoDBCRUD"
    effect    = "Allow"
    actions   = ["dynamodb:BatchGetItem", "dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.hub-out.arn, "${aws_dynamodb_table.hub-out.arn}/*"]
  }
  statement {
    sid       = "AllowLambdaInvoke"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.hub-fn.arn]
  }
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.hub-demo.arn]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.hub-demo.arn}/*"]
  }
  statement {
    sid       = "AllowSecretAccess"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue"]
    resources = [aws_secretsmanager_secret.hub-secret.arn]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.hub-topic.arn]
  }
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.hub-in.arn]
  }
  statement {
    sid       = "AllowReadParam"
    effect    = "Allow"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:PutParameter"]
    resources = [aws_ssm_parameter.hub-param.arn]
  }
}

resource "aws_iam_policy" "ecs_task_definition_hub_st_hub-state" {
  name        = "ecs_task_definition_hub_st_hub-state"
  description = "Access Policy for hub"
  policy      = data.aws_iam_policy_document.ecs_task_definition_hub_st_hub-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_hub-fn_st_hub-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.hub-fn-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_hub-fn_st_hub-state" {
  name        = "lambda_function_hub-fn_st_hub-state"
  description = "Access Policy for hub-fn"
  policy      = data.aws_iam_policy_document.lambda_function_hub-fn_st_hub-state_doc.json
}

resource "aws_iam_role" "execution_role_ecs_hub" {
  name                  = "execution_role_ecs_hub"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "execution_role_ecs_hub"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "hub-fn_role" {
  name                  = "hub-fn_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "hub-fn_role"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "task_role_ecs_hub" {
  name                  = "task_role_ecs_hub"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "task_role_ecs_hub"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_hub_execution_st_hub-state_attach" {
  policy_arn = aws_iam_policy.ecs_task_definition_hub_execution_st_hub-state.arn
  role       = aws_iam_role.execution_role_ecs_hub.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_hub_st_hub-state_attach" {
  policy_arn = aws_iam_policy.ecs_task_definition_hub_st_hub-state.arn
  role       = aws_iam_role.task_role_ecs_hub.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_hub-fn_st_hub-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_hub-fn_st_hub-state.arn
  role       = aws_iam_role.hub-fn_role.name
}

resource "aws_secretsmanager_secret" "hub-secret" {
  name                    = "hub-secret"
  description             = "Destination secret for the messages this workload forwards. Each delivery stores the message as a new current version, so a read returns the one that arrived last."
  recovery_window_in_days = 0
  tags = {
    Name           = "hub-secret"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret_version" "hub-secret_version" {
  secret_id      = aws_secretsmanager_secret.hub-secret.id
  secret_string  = "{\"demo\":\"this value is never written to the report\"}"
  version_stages = ["AWSCURRENT"]
  lifecycle {
    ignore_changes = [version_stages]
  }
}
