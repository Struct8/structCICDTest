resource "aws_sns_topic" "alerts" {
  name = "alerts"
  tags = {
    Name           = "alerts"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
  depends_on = [module.dados.aws_sqs_queue_policy_archive_st_modlab_a_id]
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
  endpoint  = module.dados.archive_arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.alerts.arn
}
