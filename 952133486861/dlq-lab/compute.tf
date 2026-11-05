resource "aws_lambda_event_source_mapping" "dlq-lab-orders-esm" {
  function_name                      = aws_lambda_function.dlq-lab-consumer.arn
  batch_size                         = 10
  event_source_arn                   = aws_sqs_queue.dlq-lab-orders-queue.arn
  function_response_types            = ["ReportBatchItemFailures"]
  maximum_batching_window_in_seconds = 5
  metrics_config {
    metrics = ["EventCount"]
  }
  tags = {
    Name           = "dlq-lab-orders-esm"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lambda_function" "dlq-lab-consumer" {
  function_name                  = "dlq-lab-consumer"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.dlq-lab-consumer_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT               = "952133486861"
      AWS_XRAY_GROUP_NAME_0 = "dlq-lab-traces"
      HUB_FAULTS            = "on"
      NAME                  = "dlq-lab-consumer"
      REGION                = "us-west-2"
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
    Name           = "dlq-lab-consumer"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_dlq-lab-consumer_st_dlq-lab_attach]
}

resource "aws_lambda_function" "dlq-lab-legacy-notifier" {
  function_name                  = "dlq-lab-legacy-notifier"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.dlq-lab-legacy-notifier_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  dead_letter_config {
    target_arn = aws_sqs_queue.dlq-lab-legacy-dlq.arn
  }
  environment {
    variables = {
      ACCOUNT               = "952133486861"
      AWS_XRAY_GROUP_NAME_0 = "dlq-lab-traces"
      HUB_FAULTS            = "on"
      NAME                  = "dlq-lab-legacy-notifier"
      REGION                = "us-west-2"
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
    Name           = "dlq-lab-legacy-notifier"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_dlq-lab-legacy-notifier_st_dlq-lab_attach]
}

resource "aws_lambda_function" "dlq-lab-notifier" {
  function_name                  = "dlq-lab-notifier"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.dlq-lab-notifier_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT                                        = "952133486861"
      AWS_LAMBDA_FUNCTION_EVENT_INVOKE_CONFIG_NAME_0 = "dlq-lab-notifier-async"
      AWS_XRAY_GROUP_NAME_0                          = "dlq-lab-traces"
      HUB_FAULTS                                     = "on"
      NAME                                           = "dlq-lab-notifier"
      REGION                                         = "us-west-2"
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
    Name           = "dlq-lab-notifier"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_dlq-lab-notifier_st_dlq-lab_attach]
}

resource "aws_lambda_function" "dlq-lab-producer" {
  function_name                  = "dlq-lab-producer"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.dlq-lab-producer_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT                        = "952133486861"
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "dlq-lab-producer-url"
      AWS_SNS_TOPIC_NAME_0           = "dlq-lab-orders"
      AWS_XRAY_GROUP_NAME_0          = "dlq-lab-traces"
      NAME                           = "dlq-lab-producer"
      REGION                         = "us-west-2"
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
    Name           = "dlq-lab-producer"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_dlq-lab-producer_st_dlq-lab_attach]
}

resource "aws_lambda_function_event_invoke_config" "dlq-lab-notifier-async" {
  function_name                = aws_lambda_function.dlq-lab-notifier.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
  destination_config {
    on_failure {
      destination = aws_sqs_queue.dlq-lab-notifier-failed.arn
    }
  }
}

resource "aws_lambda_function_url" "dlq-lab-producer-url" {
  function_name      = aws_lambda_function.dlq-lab-producer.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_dlq-lab-producer-url_to_dlq-lab-producer" {
  function_name          = aws_lambda_function.dlq-lab-producer.function_name
  statement_id           = "perm_aws_lambda_function_url_dlq-lab-producer-url_to_dlq-lab-producer0cef37394cd028c2dc62d87e37"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.dlq-lab-producer-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_dlq-lab-producer-url_to_dlq-lab-producer_invoke" {
  function_name            = aws_lambda_function.dlq-lab-producer.function_name
  statement_id             = "perm_aws_lambda_function_url_dlq-lab-producer-url_to_dlq-lab-produ6917ff8939f90ac26759bb460b934b43c1"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.dlq-lab-producer-url, aws_lambda_permission.perm_aws_lambda_function_url_dlq-lab-producer-url_to_dlq-lab-producer]
}

resource "aws_lambda_permission" "perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-legacy-notifier" {
  function_name = aws_lambda_function.dlq-lab-legacy-notifier.function_name
  statement_id  = "perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-legacy-notifierb226f38d0b0c288c5d78fd3ca9"
  principal     = "sns.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_sns_topic.dlq-lab-orders.arn
}

resource "aws_lambda_permission" "perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-notifier" {
  function_name = aws_lambda_function.dlq-lab-notifier.function_name
  statement_id  = "perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-notifier98e3917557154d5af60a43353d"
  principal     = "sns.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_sns_topic.dlq-lab-orders.arn
}
