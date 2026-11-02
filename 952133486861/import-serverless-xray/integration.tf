resource "aws_sqs_queue" "order-processing" {
  name                              = "order-processing"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "order-processing"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_order-processing_st_import-serverless-xray_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.order-processing.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_order-processing_st_import-serverless-xray" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_order-processing_st_import-serverless-xray_doc.json
  queue_url = aws_sqs_queue.order-processing.id
}

resource "aws_sns_topic" "order-events" {
  name           = "order-events"
  tracing_config = "Active"
  tags = {
    Name           = "order-events"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_xray_resource_policy.aws_xray_resource_policy_st_serverless-xray_d028c50b4f, aws_sqs_queue_policy.aws_sqs_queue_policy_order-processing_st_import-serverless-xray]
}

resource "aws_sns_topic_subscription" "Subb" {
  endpoint             = aws_sqs_queue.order-processing.arn
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = aws_sns_topic.order-events.arn
}
