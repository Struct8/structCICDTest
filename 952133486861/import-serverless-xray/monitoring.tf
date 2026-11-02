resource "aws_cloudwatch_log_group" "api-handler-logs" {
  name              = "/aws/lambda/api-handler"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "api-handler-logs"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "async-worker-logs" {
  name              = "/aws/lambda/async-worker"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "async-worker-logs"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_xray_group" "serverless-demo-traces" {
  group_name        = "serverless-demo-traces"
  filter_expression = "service(\"api-handler\") OR service(\"async-worker\") OR service(\"order-events\") OR service(\"xray-demo-api/prod\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "serverless-demo-traces"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_xray_resource_policy_st_serverless-xray_d028c50b4f_doc" {
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

resource "aws_xray_resource_policy" "aws_xray_resource_policy_st_serverless-xray_d028c50b4f" {
  policy_name     = "aws_xray_resource_policy_st_serverless-xray_d028c50b4f"
  policy_document = data.aws_iam_policy_document.aws_xray_resource_policy_st_serverless-xray_d028c50b4f_doc.json
}

resource "aws_xray_sampling_rule" "demo-sample-all" {
  version        = 1
  rule_name      = "demo-sample-all"
  service_name   = "*"
  fixed_rate     = 1
  host           = "*"
  http_method    = "*"
  priority       = 100
  reservoir_size = 1
  resource_arn   = "*"
  service_type   = "*"
  url_path       = "*"
  tags = {
    Name           = "demo-sample-all"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}
