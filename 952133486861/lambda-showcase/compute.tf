resource "aws_lambda_alias" "prod" {
  function_name    = aws_lambda_function.worker.function_name
  name             = "prod"
  description      = "Alias named prod, pointing at the version the latest deploy published. It is the stable name the runtime and concurrency settings reference, so they follow a published version instead of a version number written by hand."
  function_version = "1"
}

resource "aws_lambda_function" "worker" {
  function_name                  = "worker"
  architectures                  = ["arm64"]
  description                    = "Node.js 22 function on arm64, with 128 MB of memory and a 15-second timeout, packaged from the worker folder of the assets repository. It publishes a new version on every deploy and writes one JSON line per run to CloudWatch Logs."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.worker_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 15
  environment {
    variables = {
      ACCOUNT                                          = data.aws_caller_identity.current.account_id
      AWS_LAMBDA_ALIAS_NAME_0                          = "prod"
      AWS_LAMBDA_FUNCTION_EVENT_INVOKE_CONFIG_NAME_0   = "async-retries"
      AWS_SNS_TOPIC_NAME_0                             = "alerts"
      LOG_LEVEL                                        = "info"
      NAME                                             = "worker"
      REGION                                           = data.aws_region.current.region
      TOPIC_ARN                                        = "arn:aws:sns:us-east-1:952133486861:alerts"
      AWS_LAMBDA_PROVISIONED_CONCURRENCY_CONFIG_NAME_0 = "prewarm"
      AWS_LAMBDA_RUNTIME_MANAGEMENT_CONFIG_NAME_0      = "runtime-pin"
    }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
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
  function_name                     = aws_lambda_function.worker.function_name
  provisioned_concurrent_executions = 2
  qualifier                         = aws_lambda_alias.prod.name
  skip_destroy                      = false
}

resource "aws_lambda_runtime_management_config" "runtime-pin" {
  function_name     = aws_lambda_function.worker.function_name
  qualifier         = aws_lambda_alias.prod.function_version
  update_runtime_on = "Auto"
}
