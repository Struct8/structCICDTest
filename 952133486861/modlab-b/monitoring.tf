resource "aws_cloudwatch_log_group" "order-approval-inbox-logs" {
  name              = "/aws/lambda/order-approval-inbox"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-approval-inbox-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-console-logs" {
  name              = "/aws/lambda/order-console"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-console-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-pack-item-logs" {
  name              = "/aws/lambda/order-pack-item"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-pack-item-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-reserve-logs" {
  name              = "/aws/lambda/order-reserve"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-reserve-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-validate-logs" {
  name              = "/aws/lambda/order-validate"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-validate-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-workflow-logs" {
  name              = "/aws/vendedlogs/states/order-workflow"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-workflow-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_metric_alarm" "order-executions-failed" {
  alarm_name          = "order-executions-failed"
  metric_name         = "ExecutionsFailed"
  alarm_actions       = [aws_sns_topic.order-events.arn]
  alarm_description   = "At least one execution of order-workflow failed in the last minute."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/States"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  dimensions = {
    StateMachineArn = aws_sfn_state_machine.order-workflow.arn
  }
  tags = {
    Name           = "order-executions-failed"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_order-events_st_modlab-b]
}

resource "aws_xray_group" "order-lab-traces" {
  group_name        = "order-lab-traces"
  filter_expression = "service(\"order-approval-inbox\") OR service(\"order-charge\") OR service(\"order-console\") OR service(\"order-events\") OR service(\"order-pack-item\") OR service(\"order-release\") OR service(\"order-reserve\") OR service(\"order-validate\") OR service(\"order-workflow\")"
  tags = {
    Name           = "order-lab-traces"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_xray_resource_policy_st_modlab-b_2d74cd14a6_doc" {
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

resource "aws_xray_resource_policy" "aws_xray_resource_policy_st_modlab-b_2d74cd14a6" {
  policy_name     = "aws_xray_resource_policy_st_modlab-b_2d74cd14a6"
  policy_document = data.aws_iam_policy_document.aws_xray_resource_policy_st_modlab-b_2d74cd14a6_doc.json
}
