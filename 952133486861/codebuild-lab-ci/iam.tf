data "aws_iam_policy_document" "codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.codebuild-lab-pr-check-logs.arn}:*"]
  }
  statement {
    sid       = "AllowUseOfConnection"
    effect    = "Allow"
    actions   = ["codeconnections:GetConnection", "codeconnections:GetConnectionToken", "codestar-connections:GetConnection", "codestar-connections:GetConnectionToken"]
    resources = [data.aws_codestarconnections_connection.codebuild-lab-github.arn]
  }
  statement {
    sid       = "PublishTestReportsOfThisProject"
    effect    = "Allow"
    actions   = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
    resources = ["arn:aws:codebuild:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:report-group/codebuild-lab-pr-check-*"]
  }
}

resource "aws_iam_policy" "codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci" {
  name        = "codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci"
  description = "Access Policy for codebuild-lab-pr-check"
  policy      = data.aws_iam_policy_document.codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci_doc.json
}

data "aws_iam_policy_document" "codebuild_project_codebuild-lab-release_st_codebuild-lab-ci_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.codebuild-lab-release-logs.arn}:*"]
  }
  statement {
    sid       = "AllowUseOfConnection"
    effect    = "Allow"
    actions   = ["codeconnections:GetConnection", "codeconnections:GetConnectionToken", "codestar-connections:GetConnection", "codestar-connections:GetConnectionToken"]
    resources = [data.aws_codestarconnections_connection.codebuild-lab-github.arn]
  }
  statement {
    sid       = "AllowPullFromRepository"
    effect    = "Allow"
    actions   = ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:CompleteLayerUpload", "ecr:GetDownloadUrlForLayer", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart"]
    resources = [aws_ecr_repository.codebuild-lab-orders.arn]
  }
  statement {
    sid       = "AllowKMSAccess"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey"]
    resources = [aws_kms_key.codebuild-lab-artifacts-key.arn]
  }
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.codebuild-lab-artifacts.arn]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
    resources = ["${aws_s3_bucket.codebuild-lab-artifacts.arn}/*"]
  }
  statement {
    sid       = "AllowBucketLevelActions1"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.codebuild-lab-cache.arn]
  }
  statement {
    sid       = "AllowObjectCRUD1"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:GetObjectVersion", "s3:PutObject"]
    resources = ["${aws_s3_bucket.codebuild-lab-cache.arn}/*"]
  }
  statement {
    sid       = "AllowEcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    sid       = "PublishTestReportsOfThisProject"
    effect    = "Allow"
    actions   = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
    resources = ["arn:aws:codebuild:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:report-group/codebuild-lab-release-*"]
  }
}

resource "aws_iam_policy" "codebuild_project_codebuild-lab-release_st_codebuild-lab-ci" {
  name        = "codebuild_project_codebuild-lab-release_st_codebuild-lab-ci"
  description = "Access Policy for codebuild-lab-release"
  policy      = data.aws_iam_policy_document.codebuild_project_codebuild-lab-release_st_codebuild-lab-ci_doc.json
}

data "aws_iam_policy_document" "codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.codebuild-lab-runner-logs.arn}:*"]
  }
  statement {
    sid       = "AllowUseOfConnection"
    effect    = "Allow"
    actions   = ["codeconnections:GetConnection", "codeconnections:GetConnectionToken", "codestar-connections:GetConnection", "codestar-connections:GetConnectionToken"]
    resources = [data.aws_codestarconnections_connection.codebuild-lab-github.arn]
  }
  statement {
    sid       = "PublishTestReportsOfThisProject"
    effect    = "Allow"
    actions   = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
    resources = ["arn:aws:codebuild:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:report-group/codebuild-lab-runner-*"]
  }
}

resource "aws_iam_policy" "codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci" {
  name        = "codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci"
  description = "Access Policy for codebuild-lab-runner"
  policy      = data.aws_iam_policy_document.codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci_doc.json
}

resource "aws_iam_role" "codebuild-lab-pr-check_role" {
  name                  = "codebuild-lab-pr-check_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codebuild.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "codebuild-lab-pr-check_role"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "codebuild-lab-release_role" {
  name                  = "codebuild-lab-release_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codebuild.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "codebuild-lab-release_role"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "codebuild-lab-runner_role" {
  name                  = "codebuild-lab-runner_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codebuild.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "codebuild-lab-runner_role"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_eventbridge_codebuild-lab-release-succeeded" {
  name                  = "role_eventbridge_codebuild-lab-release-succeeded"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"events.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_eventbridge_codebuild-lab-release-succeeded"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci_attach" {
  policy_arn = aws_iam_policy.codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci.arn
  role       = aws_iam_role.codebuild-lab-pr-check_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_project_codebuild-lab-release_st_codebuild-lab-ci_attach" {
  policy_arn = aws_iam_policy.codebuild_project_codebuild-lab-release_st_codebuild-lab-ci.arn
  role       = aws_iam_role.codebuild-lab-release_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci_attach" {
  policy_arn = aws_iam_policy.codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci.arn
  role       = aws_iam_role.codebuild-lab-runner_role.name
}

resource "aws_kms_key" "codebuild-lab-artifacts-key" {
  bypass_policy_lockout_safety_check = false
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  is_enabled                         = true
  key_usage                          = "ENCRYPT_DECRYPT"
  multi_region                       = false
  policy                             = "{\"Statement\":[{\"Action\":\"kms:*\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::952133486861:root\"},\"Resource\":\"*\",\"Sid\":\"Enable IAM User Permissions\"}],\"Version\":\"2012-10-17\"}"
  rotation_period_in_days            = 365
  lifecycle {
    ignore_changes = [bypass_policy_lockout_safety_check, deletion_window_in_days]
  }
  tags = {
    Name           = "codebuild-lab-artifacts-key"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}
