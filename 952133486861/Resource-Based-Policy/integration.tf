resource "aws_sqs_queue" "Queue1" {
  name                              = "Queue1"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "Queue1"
    State          = "Resource-Based-Policy"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy_doc" {
  statement {
    sid    = "AllowEventBridgeToSendMessageToSQS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.Queue1.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.Queue1.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy_doc.json
  queue_url = aws_sqs_queue.Queue1.id
}

resource "aws_cloudwatch_event_rule" "Rule1" {
  name                = "Rule1"
  schedule_expression = "rate(5 minutes)"
  state               = "ENABLED"
  tags = {
    Name           = "Rule1"
    State          = "Resource-Based-Policy"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy]
}

resource "aws_cloudwatch_event_rule" "Rule2" {
  name                = "Rule2"
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
  tags = {
    Name           = "Rule2"
    State          = "Resource-Based-Policy"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy]
}

resource "aws_cloudwatch_event_target" "Target1" {
  arn  = aws_sqs_queue.Queue1.arn
  rule = aws_cloudwatch_event_rule.Rule1.name
}

resource "aws_cloudwatch_event_target" "Target2" {
  arn  = aws_sqs_queue.Queue1.arn
  rule = aws_cloudwatch_event_rule.Rule2.name
}
