data "aws_iam_policy_document" "lambda_function_ProcessCUR_st_CostUsageReport_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.ProcessCUR.arn}:*"]
  }
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:PutObject"]
    resources = [aws_s3_bucket.your-bucket-cost-usage-report.arn]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.your-bucket-cost-usage-report.arn}/*"]
  }
  statement {
    sid       = "AllowResolveUntaggedIPv4Owner"
    effect    = "Allow"
    actions   = ["ec2:DescribeAddresses", "ec2:DescribeNatGateways", "ec2:DescribeNetworkInterfaces", "ec2:DescribeTags", "elasticloadbalancing:DescribeLoadBalancers", "elasticloadbalancing:DescribeTags"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_ProcessCUR_st_CostUsageReport" {
  name        = "lambda_function_ProcessCUR_st_CostUsageReport"
  description = "Access Policy for ProcessCUR"
  policy      = data.aws_iam_policy_document.lambda_function_ProcessCUR_st_CostUsageReport_doc.json
}

resource "aws_iam_role" "ProcessCUR_role" {
  name = "ProcessCUR_role"
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
    Name           = "ProcessCUR_role"
    State          = "CostUsageReport"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_ProcessCUR_st_CostUsageReport_attach" {
  policy_arn = aws_iam_policy.lambda_function_ProcessCUR_st_CostUsageReport.arn
  role       = aws_iam_role.ProcessCUR_role.name
}
