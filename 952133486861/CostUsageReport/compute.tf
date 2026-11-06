data "archive_file" "archive_CloudMan_ProcessCUR" {
  output_path = "${path.module}/CloudMan_ProcessCUR.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/ProcessCUR"
  type        = "zip"
}

resource "aws_lambda_function" "ProcessCUR" {
  function_name                  = "ProcessCUR"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_CloudMan_ProcessCUR.output_path
  handler                        = "ProcessCUR.lambda_handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.ProcessCUR_role.arn
  runtime                        = "python3.13"
  source_code_hash               = data.archive_file.archive_CloudMan_ProcessCUR.output_base64sha256
  timeout                        = 120
  environment {
    variables = {
      DAYS_TO_RETAIN       = "60"
      MONTHS_TO_RETAIN     = "24"
      NAME                 = "ProcessCUR"
      REGION               = data.aws_region.current.region
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0 = "struct8-lab-cur-952133486861-usw2"
    }
  }
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
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
