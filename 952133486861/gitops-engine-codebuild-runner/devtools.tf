resource "aws_codebuild_project" "gitopslab-engine" {
  source {
    git_clone_depth     = 1
    location            = "https://github.com/Struct8/codebuild-lab.git"
    report_build_status = false
    type                = "GITHUB"
    auth {
      resource = "arn:aws:codeconnections:us-west-2:952133486861:connection/4f2f83ba-5ad2-4786-bd23-503d24564cbf"
      type     = "CODECONNECTIONS"
    }
  }
  name             = "gitopslab-engine"
  auto_retry_limit = 0
  build_timeout    = 480
  description      = "Runs the GitOps engine's GitHub Actions jobs whose runs-on label names this project."
  encryption_key   = "arn:aws:kms:us-west-2:952133486861:alias/aws/s3"
  service_role     = aws_iam_role.gitopslab-engine_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type = "NO_CACHE"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:8.0"
    privileged_mode = true
    type            = "LINUX_CONTAINER"
    environment_variable {
      name  = "NAME"
      type  = "PLAINTEXT"
      value = "gitopslab-engine"
    }
    environment_variable {
      name  = "REGION"
      type  = "PLAINTEXT"
      value = "us-west-2"
    }
    environment_variable {
      name  = "ACCOUNT"
      type  = "PLAINTEXT"
      value = "952133486861"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_ARN_0"
      type  = "PLAINTEXT"
      value = "arn:aws:codeconnections:us-west-2:952133486861:connection/4f2f83ba-5ad2-4786-bd23-503d24564cbf"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_NAME_0"
      type  = "PLAINTEXT"
      value = "gitopslab-engine-github"
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.struct8-engine-logs.name
      status     = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  tags = {
    Name           = "gitopslab-engine"
    State          = "gitops-engine-codebuild-runner"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.codebuild_project_gitopslab-engine_st_gitops-engine-codebuild-runner_attach, time_sleep.gitopslab-engine_role_propagation]
}

resource "aws_codebuild_webhook" "gitopslab-engine_webhook" {
  project_name = aws_codebuild_project.gitopslab-engine.name
  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = "WORKFLOW_JOB_QUEUED"
      type                    = "EVENT"
    }
  }
  pull_request_build_policy {
    approver_roles            = ["GITHUB_ADMIN", "GITHUB_MAINTAIN", "GITHUB_WRITE"]
    requires_comment_approval = "ALL_PULL_REQUESTS"
  }
}
