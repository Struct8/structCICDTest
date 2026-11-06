data "aws_iam_policy_document" "cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration_doc" {
  statement {
    sid       = "AllowEventBridgeToStartBuild"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.codebuild-lab-integration.arn]
  }
}

resource "aws_iam_policy" "cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration" {
  name        = "cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration"
  description = "Access Policy for codebuild-lab-nightly"
  policy      = data.aws_iam_policy_document.cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration_doc.json
}

data "aws_iam_policy_document" "cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci_doc" {
  statement {
    sid       = "AllowEventBridgeToStartBuild"
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.codebuild-lab-integration.arn]
  }
}

resource "aws_iam_policy" "cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci" {
  name        = "cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci"
  description = "Access Policy for codebuild-lab-release-succeeded"
  policy      = data.aws_iam_policy_document.cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci_doc.json
}

data "aws_iam_policy_document" "codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.codebuild-lab-integration-logs.arn}:*"]
  }
  statement {
    sid       = "AllowUseOfConnection"
    effect    = "Allow"
    actions   = ["codeconnections:GetConnection", "codeconnections:GetConnectionToken", "codestar-connections:GetConnection", "codestar-connections:GetConnectionToken"]
    resources = [data.aws_codestarconnections_connection.codebuild-lab-github.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccesscodebuildlabordersdb"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.codebuild-lab-orders-db.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "DescribeAndManageNetworkInterfaces"
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeDhcpOptions", "ec2:DescribeNetworkInterfaces", "ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeVpcs"]
    resources = ["*"]
  }
  statement {
    sid       = "PublishTestReportsOfThisProject"
    effect    = "Allow"
    actions   = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
    resources = ["arn:aws:codebuild:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:report-group/codebuild-lab-integration-*"]
  }
  statement {
    sid       = "AttachNetworkInterfacesInTheProjectSubnets"
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["arn:aws:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"
      values   = [aws_subnet.codebuild-lab-build-a.arn, aws_subnet.codebuild-lab-build-b.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration" {
  name        = "codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration"
  description = "Access Policy for codebuild-lab-integration"
  policy      = data.aws_iam_policy_document.codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration_doc.json
}

resource "aws_iam_role" "codebuild-lab-integration_role" {
  name = "codebuild-lab-integration_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "codebuild-lab-integration_role"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_eventbridge_codebuild-lab-nightly" {
  name = "role_eventbridge_codebuild-lab-nightly"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      }
    }
  ]
})
  tags = {
    Name           = "role_eventbridge_codebuild-lab-nightly"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration_attach" {
  policy_arn = aws_iam_policy.cloudwatch_event_rule_codebuild-lab-nightly_st_codebuild-lab-integration.arn
  role       = aws_iam_role.role_eventbridge_codebuild-lab-nightly.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci_attach" {
  policy_arn = aws_iam_policy.cloudwatch_event_rule_codebuild-lab-release-succeeded_st_codebuild-lab-ci.arn
  role       = data.aws_iam_role.role_eventbridge_codebuild-lab-release-succeeded.name
}

resource "aws_iam_role_policy_attachment" "codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration_attach" {
  policy_arn = aws_iam_policy.codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration.arn
  role       = aws_iam_role.codebuild-lab-integration_role.name
}
