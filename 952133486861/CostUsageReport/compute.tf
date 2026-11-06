resource "aws_lambda_function" "ProcessCUR" {
  function_name                  = "ProcessCUR"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "ProcessCUR.lambda_handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.ProcessCUR_role.arn
  runtime                        = "python3.13"
  timeout                        = 120
  environment {
    variables = {
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0 = "struct8-lab-cur-952133486861-usw2"
      DAYS_TO_RETAIN       = "60"
      MONTHS_TO_RETAIN     = "24"
      NAME                 = "ProcessCUR"
      REGION               = data.aws_region.current.region
    }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "ProcessCUR"
    State          = "CostUsageReport"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_ProcessCUR_st_CostUsageReport_attach]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_your-bucket-cost-usage-report_to_ProcessCUR" {
  function_name       = aws_lambda_function.ProcessCUR.function_name
  principal           = "s3.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_s3_bucket.your-bucket-cost-usage-report.arn
  statement_id_prefix = "perm_aws_s3_bucket_your-bucket-cost-usage-report_to_ProcessCUR"
}
