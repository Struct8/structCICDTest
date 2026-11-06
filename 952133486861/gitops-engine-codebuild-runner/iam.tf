data "aws_iam_policy_document" "codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.struct8-engine-logs.arn}:*"]
  }
  statement {
    sid       = "PublishTestReportsOfThisProject"
    effect    = "Allow"
    actions   = ["codebuild:BatchPutCodeCoverages", "codebuild:BatchPutTestCases", "codebuild:CreateReport", "codebuild:CreateReportGroup", "codebuild:UpdateReport"]
    resources = ["arn:aws:codebuild:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:report-group/gitopslab-engine-*"]
  }
  statement {
    sid       = "AllowUseOfConnection"
    effect    = "Allow"
    actions   = ["codeconnections:GetConnection", "codeconnections:GetConnectionToken", "codestar-connections:GetConnection", "codestar-connections:GetConnectionToken"]
    resources = ["arn:aws:codeconnections:us-west-2:952133486861:connection/4f2f83ba-5ad2-4786-bd23-503d24564cbf"]
  }
}

resource "aws_iam_policy" "codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner" {
  name        = "codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner"
  description = "Access Policy for gitopslab-engine"
  policy      = data.aws_iam_policy_document.codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner_doc.json
}

resource "aws_iam_role" "gitopslab-engine_role" {
  name                  = "gitopslab-engine_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"codebuild.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "gitopslab-engine_role"
    State          = "gitops-engine-codebuild-runner"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner_attach" {
  policy_arn = aws_iam_policy.codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner.arn
  role       = aws_iam_role.gitopslab-engine_role.name
}
