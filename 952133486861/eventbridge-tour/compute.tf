resource "aws_lambda_event_source_mapping" "queue-to-consumer-a" {
  function_name           = aws_lambda_function.fanout-consumer-a.arn
  batch_size              = 10
  event_source_arn        = aws_sqs_queue.fanout-queue.arn
  function_response_types = ["ReportBatchItemFailures"]
  tags = {
    Name           = "queue-to-consumer-a"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

data "archive_file" "archive_struct8-hub_fanout-consumer-a" {
  output_path = "${path.module}/struct8-hub_fanout-consumer-a.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "fanout-consumer-a" {
  function_name                  = "fanout-consumer-a"
  architectures                  = ["arm64"]
  description                    = "Fan-out consumer A. Reached THREE ways: directly by rule-fanout (EventBridge), via SNS subscription, and by polling fanout-queue (event source mapping). Active Tracing on - its log shows origin aws.events vs aws:sns."
  filename                       = data.archive_file.archive_struct8-hub_fanout-consumer-a.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.fanout-consumer-a_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_fanout-consumer-a.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                  = "fanout-consumer-a"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_XRAY_GROUP_NAME_0 = "tour-xray"
    }
  }
  tags = {
    Name           = "fanout-consumer-a"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_fanout-consumer-a_st_eventbridge-tour_attach]
}

data "archive_file" "archive_struct8-hub_fanout-consumer-b" {
  output_path = "${path.module}/struct8-hub_fanout-consumer-b.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "fanout-consumer-b" {
  function_name                  = "fanout-consumer-b"
  architectures                  = ["arm64"]
  description                    = "Fan-out consumer B. Same event as consumer A (proves one event reaches two Lambdas). Its target uses an Input Transformer, so it receives a reshaped payload, not the raw event. Active Tracing on."
  filename                       = data.archive_file.archive_struct8-hub_fanout-consumer-b.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.fanout-consumer-b_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_fanout-consumer-b.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                  = "fanout-consumer-b"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_XRAY_GROUP_NAME_0 = "tour-xray"
    }
  }
  tags = {
    Name           = "fanout-consumer-b"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_fanout-consumer-b_st_eventbridge-tour_attach]
}

data "archive_file" "archive_struct8-hub_schedule-target-fn" {
  output_path = "${path.module}/struct8-hub_schedule-target-fn.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "schedule-target-fn" {
  function_name                  = "schedule-target-fn"
  architectures                  = ["arm64"]
  description                    = "Invoked every minute by rule-schedule-5min. Doubles as the PRODUCER: its code calls PutEvents on tour-bus (custom bus), demonstrating workload -> custom bus. Active Tracing on."
  filename                       = data.archive_file.archive_struct8-hub_schedule-target-fn.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.schedule-target-fn_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_schedule-target-fn.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                            = "schedule-target-fn"
      REGION                          = data.aws_region.current.region
      ACCOUNT                         = data.aws_caller_identity.current.account_id
      AWS_CLOUDWATCH_EVENT_BUS_NAME_0 = "tour-bus"
      AWS_XRAY_GROUP_NAME_0           = "tour-xray"
    }
  }
  tags = {
    Name           = "schedule-target-fn"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_schedule-target-fn_st_eventbridge-tour_attach]
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-a" {
  function_name       = aws_lambda_function.fanout-consumer-a.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.rule-fanout.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-a"
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-b" {
  function_name       = aws_lambda_function.fanout-consumer-b.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.rule-fanout.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-b"
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_rule-schedule-1min_to_schedule-target-fn" {
  function_name       = aws_lambda_function.schedule-target-fn.function_name
  principal           = "events.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_cloudwatch_event_rule.rule-schedule-1min.arn
  statement_id_prefix = "perm_aws_cloudwatch_event_rule_rule-schedule-1min_to_schedule-target-fn"
}

resource "aws_lambda_permission" "perm_aws_sns_topic_fanout-topic_to_fanout-consumer-a" {
  function_name       = aws_lambda_function.fanout-consumer-a.function_name
  principal           = "sns.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_sns_topic.fanout-topic.arn
  statement_id_prefix = "perm_aws_sns_topic_fanout-topic_to_fanout-consumer-a"
}
