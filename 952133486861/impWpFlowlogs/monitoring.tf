resource "aws_cloudwatch_log_group" "wpReadCanaryLogs" {
  name              = "/aws/lambda/${element(split(":", aws_synthetics_canary.wpReadCanary.engine_arn), 6)}"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  tags = {
    Name           = "wpReadCanaryLogs"
    State          = "wp-flowlogs"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_prometheus_workspace" "wp-flowlogs-amp" {
  alias = "wp-flowlogs-amp"
  tags = {
    Name              = "wp-flowlogs-amp"
    State             = "wp-flowlogs"
    Struct8Creator    = "rmay struct"
    Struct8Management = "Struct8Flow"
  }
}

resource "aws_prometheus_workspace_configuration" "wp-flowlogs-amp_configuration" {
  workspace_id                        = aws_prometheus_workspace.wp-flowlogs-amp.id
  out_of_order_time_window_in_seconds = 600
  retention_period_in_days            = 30
  rule_query_offset_in_seconds        = 60
}

resource "aws_synthetics_canary" "wpReadCanary" {
  name                 = "wpreadcanary"
  artifact_s3_location = "s3://${aws_s3_bucket.canaryArtifacts.bucket}/canary/wpreadcanary"
  delete_lambda        = true
  execution_role_arn   = aws_iam_role.wpReadCanary_role.arn
  handler              = "index.handler"
  runtime_version      = "syn-nodejs-playwright-9.0"
  start_canary         = true
  lifecycle {
    ignore_changes = [run_config, start_canary]
  }
  run_config {
    active_tracing     = false
    ephemeral_storage  = 1024
    memory_in_mb       = 960
    timeout_in_seconds = 120
    environment_variables = {
      ACCOUNT              = "952133486861"
      AWS_S3_BUCKET_NAME_0 = "canaryartifacts-952133486861-us-west-2-an"
      NAME                 = "wpReadCanary"
      REGION               = "us-west-2"
      TARGET_URL           = "https://wp.cloudman.pro/"
    }
  }
  schedule {
    expression = "rate(5 minutes)"
    retry_config {
      max_retries = 0
    }
  }
  tags = {
    Name           = "wpReadCanary"
    State          = "wp-flowlogs"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.synthetics_canary_wpReadCanary_st_wp-flowlogs_attach]
}
