resource "aws_codebuild_project" "codebuild-lab-pr-check" {
  source {
    buildspec           = "buildspec/pr-check.yml"
    git_clone_depth     = 1
    location            = "https://github.com/Struct8/codebuild-lab.git"
    report_build_status = true
    type                = "GITHUB"
    auth {
      resource = data.aws_codestarconnections_connection.codebuild-lab-github.arn
      type     = "CODECONNECTIONS"
    }
  }
  name             = "codebuild-lab-pr-check"
  auto_retry_limit = 0
  build_timeout    = 15
  description      = "Unit tests and coverage of each pull request on Lambda compute."
  encryption_key   = "arn:aws:kms:us-west-2:952133486861:alias/aws/s3"
  service_role     = aws_iam_role.codebuild-lab-pr-check_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type = "NO_CACHE"
  }
  environment {
    compute_type = "BUILD_LAMBDA_1GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs22"
    type         = "LINUX_LAMBDA_CONTAINER"
    environment_variable {
      name  = "NAME"
      type  = "PLAINTEXT"
      value = "codebuild-lab-pr-check"
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
      value = "arn:aws:codeconnections:us-west-2:952133486861:connection/e6535080-d42a-4a04-a298-6df6ffd54fc4"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-github"
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild-lab-pr-check-logs.name
      status     = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  tags = {
    Name           = "codebuild-lab-pr-check"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-pr-check_st_codebuild-lab-ci_attach, time_sleep.codebuild-lab-pr-check_role_propagation]
}

resource "aws_codebuild_project" "codebuild-lab-release" {
  source {
    buildspec           = "buildspec/release.yml"
    git_clone_depth     = 1
    location            = "https://github.com/Struct8/codebuild-lab.git"
    report_build_status = true
    type                = "GITHUB"
    auth {
      resource = data.aws_codestarconnections_connection.codebuild-lab-github.arn
      type     = "CODECONNECTIONS"
    }
  }
  name                   = "codebuild-lab-release"
  auto_retry_limit       = 0
  badge_enabled          = true
  build_timeout          = 30
  concurrent_build_limit = 1
  description            = "Image to ECR tagged with the commit and release zip to S3 on each push to main."
  encryption_key         = aws_kms_key.codebuild-lab-artifacts-key.arn
  service_role           = aws_iam_role.codebuild-lab-release_role.arn
  artifacts {
    name                   = "release.zip"
    override_artifact_name = false
    encryption_disabled    = false
    location               = aws_s3_bucket.codebuild-lab-artifacts.bucket
    namespace_type         = "BUILD_ID"
    packaging              = "ZIP"
    type                   = "S3"
  }
  cache {
    location = aws_s3_bucket.codebuild-lab-cache.bucket
    type     = "S3"
  }
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    privileged_mode = true
    type            = "LINUX_CONTAINER"
    environment_variable {
      name  = "IMAGE_REPO_URL"
      type  = "PLAINTEXT"
      value = "952133486861.dkr.ecr.us-west-2.amazonaws.com/codebuild-lab-orders"
    }
    environment_variable {
      name  = "NAME"
      type  = "PLAINTEXT"
      value = "codebuild-lab-release"
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
      value = "arn:aws:codeconnections:us-west-2:952133486861:connection/e6535080-d42a-4a04-a298-6df6ffd54fc4"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-github"
    }
    environment_variable {
      name  = "AWS_S3_BUCKET_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-cache-952133486861-us-west-2-an"
    }
    environment_variable {
      name  = "AWS_KMS_KEY_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-artifacts-key"
    }
    environment_variable {
      name  = "AWS_ECR_REPOSITORY_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-orders"
    }
    environment_variable {
      name  = "AWS_ECR_REPOSITORY_URL_0"
      type  = "PLAINTEXT"
      value = "952133486861.dkr.ecr.us-west-2.amazonaws.com/codebuild-lab-orders"
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild-lab-release-logs.name
      status     = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  tags = {
    Name           = "codebuild-lab-release"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-release_st_codebuild-lab-ci_attach, time_sleep.codebuild-lab-release_role_propagation]
}

resource "aws_codebuild_project" "codebuild-lab-runner" {
  source {
    git_clone_depth     = 1
    location            = "https://github.com/Struct8/codebuild-lab.git"
    report_build_status = false
    type                = "GITHUB"
    auth {
      resource = data.aws_codestarconnections_connection.codebuild-lab-github.arn
      type     = "CODECONNECTIONS"
    }
  }
  name             = "codebuild-lab-runner"
  auto_retry_limit = 0
  build_timeout    = 30
  description      = "Runs the GitHub Actions jobs whose runs-on label names this project."
  encryption_key   = "arn:aws:kms:us-west-2:952133486861:alias/aws/s3"
  service_role     = aws_iam_role.codebuild-lab-runner_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type = "NO_CACHE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux-aarch64-standard:3.0"
    type         = "ARM_CONTAINER"
    environment_variable {
      name  = "NAME"
      type  = "PLAINTEXT"
      value = "codebuild-lab-runner"
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
      value = "arn:aws:codeconnections:us-west-2:952133486861:connection/e6535080-d42a-4a04-a298-6df6ffd54fc4"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-github"
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild-lab-runner-logs.name
      status     = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }
  tags = {
    Name           = "codebuild-lab-runner"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-runner_st_codebuild-lab-ci_attach, time_sleep.codebuild-lab-runner_role_propagation]
}

resource "aws_codebuild_webhook" "codebuild-lab-pr-check_webhook" {
  project_name = aws_codebuild_project.codebuild-lab-pr-check.name
  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = "PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED, PULL_REQUEST_REOPENED"
      type                    = "EVENT"
    }
    filter {
      exclude_matched_pattern = false
      pattern                 = "^refs/heads/main$"
      type                    = "BASE_REF"
    }
  }
  pull_request_build_policy {
    approver_roles            = ["GITHUB_ADMIN", "GITHUB_MAINTAIN", "GITHUB_WRITE"]
    requires_comment_approval = "ALL_PULL_REQUESTS"
  }
}

resource "aws_codebuild_webhook" "codebuild-lab-release_webhook" {
  project_name = aws_codebuild_project.codebuild-lab-release.name
  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = "PUSH"
      type                    = "EVENT"
    }
    filter {
      exclude_matched_pattern = false
      pattern                 = "^refs/heads/main$"
      type                    = "HEAD_REF"
    }
  }
  pull_request_build_policy {
    approver_roles            = ["GITHUB_ADMIN", "GITHUB_MAINTAIN", "GITHUB_WRITE"]
    requires_comment_approval = "ALL_PULL_REQUESTS"
  }
}

resource "aws_codebuild_webhook" "codebuild-lab-runner_webhook" {
  project_name = aws_codebuild_project.codebuild-lab-runner.name
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
