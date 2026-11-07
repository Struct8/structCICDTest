resource "aws_sqs_queue" "order-approvals" {
  name                              = "order-approvals"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "order-approvals"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sqs_queue" "order-notifications" {
  name                              = "order-notifications"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "order-notifications"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_order-notifications_st_modlab-b_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.order-notifications.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_order-notifications_st_modlab-b" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_order-notifications_st_modlab-b_doc.json
  queue_url = aws_sqs_queue.order-notifications.id
}

resource "aws_sns_topic" "order-events" {
  name           = "order-events"
  tracing_config = "Active"
  tags = {
    Name           = "order-events"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_order-notifications_st_modlab-b, aws_xray_resource_policy.aws_xray_resource_policy_st_modlab-b_2d74cd14a6]
}

data "aws_iam_policy_document" "aws_sns_topic_policy_order-events_st_modlab-b_doc" {
  statement {
    sid    = "AllowCloudWatchAlarmsToPublish"
    effect = "Allow"
    principals {
      identifiers = ["cloudwatch.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowEventBridgeToPublishToSNS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_order-events_st_modlab-b" {
  arn    = aws_sns_topic.order-events.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_order-events_st_modlab-b_doc.json
}

resource "aws_sns_topic_subscription" "events-to-notifications" {
  endpoint  = aws_sqs_queue.order-notifications.arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.order-events.arn
}

resource "aws_cloudwatch_event_rule" "order-failure-alerts" {
  name        = "order-failure-alerts"
  description = "Executions of order-workflow that end FAILED, TIMED_OUT or ABORTED."
  event_pattern = <<EOF
{
  "source": ["aws.states"],
  "detail-type": ["Step Functions Execution Status Change"],
  "detail": {
    "status": ["FAILED", "TIMED_OUT", "ABORTED"],
    "stateMachineArn": ["${aws_sfn_state_machine.order-workflow.arn}"]
  }
}
  EOF
  state = "ENABLED"
  tags = {
    Name           = "order-failure-alerts"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_order-events_st_modlab-b]
}

resource "aws_cloudwatch_event_target" "failure-alerts-to-events" {
  arn  = aws_sns_topic.order-events.arn
  rule = aws_cloudwatch_event_rule.order-failure-alerts.name
}

resource "aws_sfn_state_machine" "order-workflow" {
  name = "order-workflow"
  definition = templatefile("${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/stepfunctions/order-workflow.asl.json", {
    aws_cloudwatch_log_group = {
      "order-workflow-logs" = aws_cloudwatch_log_group.order-workflow-logs
    }
    aws_dynamodb_table = {
      "order-lab-data" = aws_dynamodb_table.order-lab-data
    }
    aws_lambda_function = {
      "order-charge"    = module.pagamento.order_charge_whole
      "order-pack-item" = aws_lambda_function.order-pack-item
      "order-release"   = module.pagamento.order_release_whole
      "order-reserve"   = aws_lambda_function.order-reserve
      "order-validate"  = aws_lambda_function.order-validate
    }
    aws_sns_topic = {
      "order-events" = aws_sns_topic.order-events
    }
    aws_sqs_queue = {
      "order-approvals" = aws_sqs_queue.order-approvals
    }
    aws_xray_group = {
      "order-lab-traces" = aws_xray_group.order-lab-traces
    }
  })
  role_arn = aws_iam_role.order-workflow_role.arn
  logging_configuration {
    include_execution_data = true
    level                  = "ALL"
    log_destination        = "${aws_cloudwatch_log_group.order-workflow-logs.arn}:*"
  }
  tags = {
    Name           = "order-workflow"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_configuration {
    enabled = true
  }
  depends_on = [aws_iam_role_policy_attachment.sfn_state_machine_order-workflow_st_modlab-b_attach]
}
