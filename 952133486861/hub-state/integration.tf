resource "aws_sqs_queue" "hub-in" {
  name                              = "hub-in"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 20
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 60
  tags = {
    Name           = "hub-in"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_hub-in_st_hub-state_doc" {
  statement {
    sid    = "AllowEventBridgeToSendMessageToSQS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.hub-in.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_hub-in_st_hub-state" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_hub-in_st_hub-state_doc.json
  queue_url = aws_sqs_queue.hub-in.id
}

resource "aws_sns_topic" "hub-topic" {
  name = "hub-topic"
  tags = {
    Name           = "hub-topic"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_rule" "hub-tick" {
  name                = "hub-tick"
  description         = "Scheduled EventBridge rule. It invokes the Lambda once an hour and is the recurring source of traffic in this diagram."
  schedule_expression = "rate(1 minute)"
  state               = "DISABLED"
  tags = {
    Name           = "hub-tick"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_hub-in_st_hub-state]
}

resource "aws_cloudwatch_event_target" "Target" {
  target_id = "terraform-ek05AmBjKHhqy01MLhePa7BPPa"
  arn       = aws_sqs_queue.hub-in.arn
  rule      = aws_cloudwatch_event_rule.hub-tick.name
}
