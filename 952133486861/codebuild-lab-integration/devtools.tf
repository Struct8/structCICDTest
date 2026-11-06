resource "aws_codebuild_project" "codebuild-lab-integration" {
  source {
    buildspec           = "buildspec/integration.yml"
    git_clone_depth     = 1
    location            = "https://github.com/Struct8/codebuild-lab.git"
    report_build_status = false
    type                = "GITHUB"
    auth {
      resource = data.aws_codestarconnections_connection.codebuild-lab-github.arn
      type     = "CODECONNECTIONS"
    }
  }
  name             = "codebuild-lab-integration"
  auto_retry_limit = 1
  build_timeout    = 20
  description      = "Migrations and integration tests against PostgreSQL inside the VPC."
  service_role     = aws_iam_role.codebuild-lab-integration_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux-x86_64-standard:6.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "NAME"
      type  = "PLAINTEXT"
      value = "codebuild-lab-integration"
    }
    environment_variable {
      name  = "REGION"
      type  = "PLAINTEXT"
      value = data.aws_region.current.region
    }
    environment_variable {
      name  = "ACCOUNT"
      type  = "PLAINTEXT"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_NAME_0"
      type  = "PLAINTEXT"
      value = aws_db_instance.codebuild-lab-orders-db.identifier
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_ENGINE_0"
      type  = "PLAINTEXT"
      value = aws_db_instance.codebuild-lab-orders-db.engine
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_ENDPOINT_0"
      type  = "PLAINTEXT"
      value = aws_db_instance.codebuild-lab-orders-db.endpoint
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_DB_NAME_0"
      type  = "PLAINTEXT"
      value = aws_db_instance.codebuild-lab-orders-db.db_name
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_SECRET_ARN_0"
      type  = "PLAINTEXT"
      value = one(aws_db_instance.codebuild-lab-orders-db.master_user_secret[*].secret_arn)
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_USER_NAME_0"
      type  = "PLAINTEXT"
      value = "${one(aws_db_instance.codebuild-lab-orders-db.master_user_secret[*].secret_arn)}:username::"
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_ARN_0"
      type  = "PLAINTEXT"
      value = data.aws_codestarconnections_connection.codebuild-lab-github.arn
    }
    environment_variable {
      name  = "AWS_CODECONNECTIONS_CONNECTION_NAME_0"
      type  = "PLAINTEXT"
      value = data.aws_codestarconnections_connection.codebuild-lab-github.name
    }
  }
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild-lab-integration-logs.name
      status     = "ENABLED"
    }
  }
  tags = {
    Name           = "codebuild-lab-integration"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    vpc_id             = aws_subnet.codebuild-lab-build-a.vpc_id
    security_group_ids = [aws_security_group.codebuild_project_codebuild-lab-integration_group.id]
    subnets            = [aws_subnet.codebuild-lab-build-a.id, aws_subnet.codebuild-lab-build-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.codebuild_project_codebuild-lab-integration_st_codebuild-lab-integration_attach, time_sleep.codebuild-lab-integration_role_propagation]
}
