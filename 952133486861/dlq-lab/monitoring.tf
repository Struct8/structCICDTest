resource "aws_cloudwatch_log_group" "dlq-lab-consumer-logs" {
  name              = "/aws/lambda/dlq-lab-consumer"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "dlq-lab-consumer-logs"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "dlq-lab-legacy-notifier-logs" {
  name              = "/aws/lambda/dlq-lab-legacy-notifier"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "dlq-lab-legacy-notifier-logs"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "dlq-lab-notifier-logs" {
  name              = "/aws/lambda/dlq-lab-notifier"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "dlq-lab-notifier-logs"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "dlq-lab-producer-logs" {
  name              = "/aws/lambda/dlq-lab-producer"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "dlq-lab-producer-logs"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq-lab-orders-dlq-not-empty" {
  alarm_name          = "dlq-lab-orders-dlq-not-empty"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  alarm_actions       = ["arn:aws:sns:us-east-1:952133486861:dlq-lab-alerts"]
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.dlq-lab-orders-dlq.name
  }
  tags = {
    Name           = "dlq-lab-orders-dlq-not-empty"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_xray_group" "dlq-lab-traces" {
  group_name        = "dlq-lab-traces"
  filter_expression = "service(\"dlq-lab-alerts\") OR service(\"dlq-lab-consumer\") OR service(\"dlq-lab-legacy-notifier\") OR service(\"dlq-lab-notifier\") OR service(\"dlq-lab-orders\") OR service(\"dlq-lab-producer\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "dlq-lab-traces"
    State          = "dlq-lab"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_xray_resource_policy_st_dlq-lab_b4702f8187_doc" {
  statement {
    sid    = "AllowSNSToSendTracesToXRay"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["xray:GetSamplingRules", "xray:GetSamplingTargets", "xray:PutTraceSegments"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "StringLike"
      values   = ["arn:aws:sns:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_xray_resource_policy" "aws_xray_resource_policy_st_dlq-lab_b4702f8187" {
  policy_name     = "aws_xray_resource_policy_st_dlq-lab_b4702f8187"
  policy_document = data.aws_iam_policy_document.aws_xray_resource_policy_st_dlq-lab_b4702f8187_doc.json
}
