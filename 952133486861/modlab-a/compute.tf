data "archive_file" "archive_struct8-hub_processor" {
  output_path = "${path.module}/struct8-hub_processor.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "processor" {
  function_name                  = "processor"
  architectures                  = ["arm64"]
  description                    = "Runs on every .csv uploaded under 'uploads/'. Code is the prebuilt Hub artifact from the connected GitHub node (Struct8/struct8-hub, folder 'prebuilt', handler index.handler). Writes to the connected CloudWatch log group, where you confirm it ran."
  filename                       = data.archive_file.archive_struct8-hub_processor.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.processor_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_processor.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME    = "processor"
      REGION  = data.aws_region.current.region
      ACCOUNT = data.aws_caller_identity.current.account_id
    }
  }
  tags = {
    Name           = "processor"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_processor_st_modlab-a_attach]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_source_to_processor" {
  function_name       = aws_lambda_function.processor.function_name
  principal           = "s3.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = module.dados.source_arn
  statement_id_prefix = "perm_aws_s3_bucket_source_to_processor"
}
