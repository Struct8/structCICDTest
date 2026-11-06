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
  encryption_key   = "arn:aws:kms:us-west-2:952133486861:alias/aws/s3"
  service_role     = aws_iam_role.codebuild-lab-integration_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  cache {
    type = "NO_CACHE"
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
      value = "us-west-2"
    }
    environment_variable {
      name  = "ACCOUNT"
      type  = "PLAINTEXT"
      value = "952133486861"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_NAME_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-orders-db"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_ENGINE_0"
      type  = "PLAINTEXT"
      value = "postgres"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_ENDPOINT_0"
      type  = "PLAINTEXT"
      value = "codebuild-lab-orders-db.c9g6oy6oylb0.us-west-2.rds.amazonaws.com:5432"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_DB_NAME_0"
      type  = "PLAINTEXT"
      value = "orders"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_SECRET_ARN_0"
      type  = "PLAINTEXT"
      value = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-68961c48-5507-4072-a98c-eeb72a218aca-UmKcma"
    }
    environment_variable {
      name  = "AWS_DB_INSTANCE_USER_NAME_0"
      type  = "PLAINTEXT"
      value = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!db-68961c48-5507-4072-a98c-eeb72a218aca-UmKcma:username::"
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
      group_name = aws_cloudwatch_log_group.codebuild-lab-integration-logs.name
      status     = "ENABLED"
    }
    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
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
