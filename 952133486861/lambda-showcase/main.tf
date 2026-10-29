terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/lambda-showcase/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

data "aws_iam_policy_document" "lambda_function_worker_st_lambda-showcase_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.worker-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
  }
}

resource "aws_iam_policy" "lambda_function_worker_st_lambda-showcase" {
  name        = "lambda_function_worker_st_lambda-showcase"
  description = "Access Policy for worker"
  policy      = data.aws_iam_policy_document.lambda_function_worker_st_lambda-showcase_doc.json
}

resource "aws_iam_role" "worker_role" {
  name = "worker_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "worker_role"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_worker_st_lambda-showcase_attach" {
  policy_arn = aws_iam_policy.lambda_function_worker_st_lambda-showcase.arn
  role       = aws_iam_role.worker_role.name
}




### CATEGORY: COMPUTE ###

resource "aws_lambda_alias" "prod" {
  function_name    = aws_lambda_function.worker.function_name
  name             = "prod"
  description      = "Alias named prod, pointing at the version the latest deploy published. It is the stable name the runtime and concurrency settings reference, so they follow a published version instead of a version number written by hand."
  function_version = aws_lambda_function.worker.version
}

data "archive_file" "archive_struct8-templates_worker" {
  output_path = "${path.module}/struct8-templates_worker.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/lambda-showcase/v1/lambda/worker"
  type        = "zip"
}

resource "aws_lambda_function" "worker" {
  function_name                  = "worker"
  architectures                  = ["arm64"]
  description                    = "Node.js 22 function on arm64, with 128 MB of memory and a 15-second timeout, packaged from the worker folder of the assets repository. It publishes a new version on every deploy and writes one JSON line per run to CloudWatch Logs."
  filename                       = data.archive_file.archive_struct8-templates_worker.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.worker_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_worker.output_base64sha256
  timeout                        = 15
  environment {
    variables = {
    LOG_LEVEL                                      = "info"
    TOPIC_ARN                                      = aws_sns_topic.alerts.arn
    NAME                                           = "worker"
    REGION                                         = data.aws_region.current.region
    ACCOUNT                                        = data.aws_caller_identity.current.account_id
    AWS_LAMBDA_ALIAS_NAME_0                        = "prod"
    AWS_LAMBDA_FUNCTION_EVENT_INVOKE_CONFIG_NAME_0 = "async-retries"
    AWS_SNS_TOPIC_NAME_0                           = "alerts"
  }
  }
  tags = {
    Name           = "worker"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_worker_st_lambda-showcase_attach]
}

resource "aws_lambda_function_event_invoke_config" "async-retries" {
  function_name                = aws_lambda_function.worker.function_name
  maximum_event_age_in_seconds = 3600
  maximum_retry_attempts       = 1
  destination_config {
    on_failure {
      destination = aws_sns_topic.alerts.arn
    }
  }
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-5-min_to_worker" {
  function_name       = aws_lambda_function.worker.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.every-5-min.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_every-5-min_to_worker"
}

resource "aws_lambda_provisioned_concurrency_config" "prewarm" {
  function_name                     = aws_lambda_alias.prod.function_name
  provisioned_concurrent_executions = 2
  qualifier                         = aws_lambda_alias.prod.name
  skip_destroy                      = false
}

resource "aws_lambda_runtime_management_config" "runtime-pin" {
  function_name     = aws_lambda_alias.prod.function_name
  qualifier         = aws_lambda_alias.prod.function_version
  update_runtime_on = "Auto"
}




### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "alerts" {
  name = "alerts"
  tags = {
    Name           = "alerts"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_rule" "every-5-min" {
  name                = "every-5-min"
  description         = "EventBridge schedule that fires every five minutes, enabled. It invokes the function asynchronously and passes the scheduled instant in the event."
  schedule_expression = "rate(5 minutes)"
  state               = "ENABLED"
  tags = {
    Name           = "every-5-min"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  arn        = aws_lambda_function.worker.arn
  rule       = aws_cloudwatch_event_rule.every-5-min.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-5-min_to_worker]
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "worker-logs" {
  name              = "/aws/lambda/worker"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "worker-logs"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}


