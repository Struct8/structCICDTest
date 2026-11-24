resource "aws_iam_policy" "lambda_function_wp-process-flow-logs_st_wp-flowlogs" {
  name        = "lambda_function_wp-process-flow-logs_st_wp-flowlogs"
  description = "Access Policy for wp-process-flow-logs"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "aps:GetLabels",
        "aps:GetMetricMetadata",
        "aps:GetSeries",
        "aps:QueryMetrics",
        "aps:RemoteWrite"
      ],
      "Resource": [
        "${aws_prometheus_workspace.wp-flowlogs-amp.arn}"
      ],
      "Sid": "AllowPrometheusRemoteWrite"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.flowlogs-bucket.arn}"
      ],
      "Sid": "AllowBucketLevelActions"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.flowlogs-bucket.arn}/*"
      ],
      "Sid": "AllowObjectCRUD"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeNatGateways",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcs",
        "elasticloadbalancing:DescribeTags",
        "lambda:ListTags",
        "rds:DescribeDBInstances",
        "rds:DescribeDBProxies",
        "tag:GetResources"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowReadingWhoOwnsEachAddress"
    }
  ]
})
}

data "aws_iam_policy_document" "synthetics_canary_wpReadCanary_st_wp-flowlogs_doc" {
  statement {
    sid       = "AllowCanaryArtifactBucketLocation"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation"]
    resources = [aws_s3_bucket.canaryArtifacts.arn]
  }
  statement {
    sid       = "AllowCanaryArtifactObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.canaryArtifacts.arn}/*"]
  }
  statement {
    sid       = "CanaryMetrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["CloudWatchSynthetics"]
    }
  }
  statement {
    sid       = "CanaryListBuckets"
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  statement {
    sid       = "CanaryLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:us-west-2:952133486861:log-group:/aws/lambda/cwsyn-*:*"]
  }
}

resource "aws_iam_policy" "synthetics_canary_wpReadCanary_st_wp-flowlogs" {
  name        = "synthetics_canary_wpReadCanary_st_wp-flowlogs"
  description = "Access Policy for wpReadCanary"
  policy      = data.aws_iam_policy_document.synthetics_canary_wpReadCanary_st_wp-flowlogs_doc.json
}

resource "aws_iam_role" "wp-process-flow-logs_role" {
  name                  = "wp-process-flow-logs_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "wp-process-flow-logs_role"
    State          = "wp-flowlogs"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "wpReadCanary_role" {
  name                  = "wpReadCanary_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "wpReadCanary_role"
    State          = "wp-flowlogs"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_wp-process-flow-logs_st_wp-flowlogs_attach_wp-process-flow-logs_role" {
  policy_arn = aws_iam_policy.lambda_function_wp-process-flow-logs_st_wp-flowlogs.arn
  role       = aws_iam_role.wp-process-flow-logs_role.name
}

resource "aws_iam_role_policy_attachment" "synthetics_canary_wpReadCanary_st_wp-flowlogs_attach" {
  policy_arn = aws_iam_policy.synthetics_canary_wpReadCanary_st_wp-flowlogs.arn
  role       = aws_iam_role.wpReadCanary_role.name
}
