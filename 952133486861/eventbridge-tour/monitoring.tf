resource "aws_cloudwatch_log_group" "logs-fanout-consumer-a" {
  name              = "/aws/lambda/fanout-consumer-a"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  tags = {
    Name           = "logs-fanout-consumer-a"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "logs-fanout-consumer-b" {
  name              = "/aws/lambda/fanout-consumer-b"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  tags = {
    Name           = "logs-fanout-consumer-b"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "logs-schedule-target-fn" {
  name              = "/aws/lambda/schedule-target-fn"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  tags = {
    Name           = "logs-schedule-target-fn"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_xray_group" "tour-xray" {
  group_name        = "tour-xray"
  filter_expression = "service(\"fanout-consumer-a\") OR service(\"fanout-consumer-b\") OR service(\"fanout-topic\") OR service(\"schedule-target-fn\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "tour-xray"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_xray_resource_policy_st_eventbridge-tour_d5b4d0b8f5_doc" {
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

resource "aws_xray_resource_policy" "aws_xray_resource_policy_st_eventbridge-tour_d5b4d0b8f5" {
  policy_name     = "aws_xray_resource_policy_st_eventbridge-tour_d5b4d0b8f5"
  policy_document = data.aws_iam_policy_document.aws_xray_resource_policy_st_eventbridge-tour_d5b4d0b8f5_doc.json
}
