resource "aws_sqs_queue" "dlq-lab-legacy-dlq" {
  name                              = "dlq-lab-legacy-dlq"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "dlq-lab-legacy-dlq"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sqs_queue" "dlq-lab-notifier-failed" {
  name                              = "dlq-lab-notifier-failed"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "dlq-lab-notifier-failed"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sqs_queue" "dlq-lab-orders-dlq" {
  name                              = "dlq-lab-orders-dlq"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "dlq-lab-orders-dlq"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sqs_queue" "dlq-lab-orders-queue" {
  name                              = "dlq-lab-orders-queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  redrive_policy                    = jsonencode({ deadLetterTargetArn = aws_sqs_queue.dlq-lab-orders-dlq.arn, maxReceiveCount = 3 })
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 60
  tags = {
    Name           = "dlq-lab-orders-queue"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_dlq-lab-orders-queue_st_dlq-lab_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq-lab-orders-queue.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_dlq-lab-orders-queue_st_dlq-lab" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_dlq-lab-orders-queue_st_dlq-lab_doc.json
  queue_url = aws_sqs_queue.dlq-lab-orders-queue.id
}

resource "aws_sns_topic" "dlq-lab-alerts" {
  name           = "dlq-lab-alerts"
  tracing_config = "Active"
  tags = {
    Name           = "dlq-lab-alerts"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_xray_resource_policy.aws_xray_resource_policy_st_dlq-lab_b4702f8187]
}

resource "aws_sns_topic" "dlq-lab-orders" {
  name           = "dlq-lab-orders"
  tracing_config = "Active"
  tags = {
    Name           = "dlq-lab-orders"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_dlq-lab-orders-queue_st_dlq-lab, aws_xray_resource_policy.aws_xray_resource_policy_st_dlq-lab_b4702f8187]
}

resource "aws_sns_topic_subscription" "Subscription2" {
  endpoint   = aws_lambda_function.dlq-lab-notifier.arn
  protocol   = "lambda"
  topic_arn  = aws_sns_topic.dlq-lab-orders.arn
  depends_on = [aws_lambda_permission.perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-notifier]
}

resource "aws_sns_topic_subscription" "Subscription3" {
  endpoint   = aws_lambda_function.dlq-lab-legacy-notifier.arn
  protocol   = "lambda"
  topic_arn  = aws_sns_topic.dlq-lab-orders.arn
  depends_on = [aws_lambda_permission.perm_aws_sns_topic_dlq-lab-orders_to_dlq-lab-legacy-notifier]
}

resource "aws_sns_topic_subscription" "Subscription4" {
  endpoint  = aws_sqs_queue.dlq-lab-orders-queue.arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.dlq-lab-orders.arn
}

resource "aws_sns_topic_subscription" "dlq-lab-alerts-email" {
  endpoint  = "example@exampl.com"
  protocol  = "email"
  topic_arn = aws_sns_topic.dlq-lab-alerts.arn
}

resource "aws_scheduler_schedule" "dlq-lab-traffic-ok" {
  name                = "dlq-lab-traffic-ok"
  schedule_expression = "rate(1 minute)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_sns_topic.dlq-lab-orders.arn
    input    = "{\"behavior\":\"ok\"}"
    role_arn = aws_iam_role.dlq-lab-traffic-ok_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 60
      maximum_retry_attempts       = 0
    }
  }
  depends_on = [aws_iam_role_policy_attachment.scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab_attach]
}
