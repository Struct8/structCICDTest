data "aws_iam_policy_document" "lambda_function_process-flow-logs_st_state-traffic-metrics_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.process-flow-logs.arn}:*"]
  }
  statement {
    sid       = "AllowPrometheusRemoteWrite"
    effect    = "Allow"
    actions   = ["aps:GetLabels", "aps:GetMetricMetadata", "aps:GetSeries", "aps:QueryMetrics", "aps:RemoteWrite"]
    resources = [aws_prometheus_workspace.vpc-traffic.arn]
  }
  statement {
    sid       = "AllowObjectRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.flowlogs-bucket.arn}/*"]
  }
  statement {
    sid       = "AllowReadingWhoOwnsEachAddress"
    effect    = "Allow"
    actions   = ["ec2:DescribeInstances", "ec2:DescribeNatGateways", "ec2:DescribeNetworkInterfaces", "ec2:DescribeVpcEndpoints", "ec2:DescribeVpcs", "elasticloadbalancing:DescribeTags", "lambda:ListTags", "rds:DescribeDBInstances", "rds:DescribeDBProxies", "tag:GetResources"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_process-flow-logs_st_state-traffic-metrics" {
  name        = "lambda_function_process-flow-logs_st_state-traffic-metrics"
  description = "Access Policy for process-flow-logs"
  policy      = data.aws_iam_policy_document.lambda_function_process-flow-logs_st_state-traffic-metrics_doc.json
}

resource "aws_iam_role" "process-flow-logs_role" {
  name = "process-flow-logs_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "process-flow-logs_role"
    State          = "state-traffic-metrics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_process-flow-logs_st_state-traffic-metrics_attach" {
  policy_arn = aws_iam_policy.lambda_function_process-flow-logs_st_state-traffic-metrics.arn
  role       = aws_iam_role.process-flow-logs_role.name
}
