resource "aws_sqs_queue" "archive" {
  name                              = "archive"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 60
  tags = {
    Name           = "archive"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_archive_st_modlab-a_doc" {
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.archive.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.archive.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_archive_st_modlab-a" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_archive_st_modlab-a_doc.json
  queue_url = aws_sqs_queue.archive.id
}

resource "aws_sns_topic" "alerts" {
  name = "alerts"
  tags = {
    Name           = "alerts"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a]
}

data "aws_iam_policy_document" "aws_sns_topic_policy_alerts_st_modlab-a_doc" {
  statement {
    sid    = "AllowS3Publish"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_alerts_st_modlab-a" {
  arn    = aws_sns_topic.alerts.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_alerts_st_modlab-a_doc.json
}

resource "aws_sns_topic_subscription" "Subscription" {
  endpoint  = aws_sqs_queue.archive.arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.alerts.arn
}
