data "archive_file" "archive_struct8-templates_Function1" {
  output_path = "${path.module}/struct8-templates_Function1.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/lambda-showcase/v1/lambda/worker"
  type        = "zip"
}

resource "aws_lambda_function" "Function1" {
  function_name                  = "Function1"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_Function1.output_path
  handler                        = "worker.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.Function1_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_Function1.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                      = "Function1"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "Table1"
      AWS_SQS_QUEUE_NAME_0      = "Queue2"
    }
  }
  tags = {
    Name           = "Function1"
    State          = "Identity-Policy"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_Function1_st_Identity-Policy_attach]
}
