data "archive_file" "archive_struct8-templates_Function3" {
  output_path = "${path.module}/struct8-templates_Function3.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/lambda-showcase/v1/lambda/worker"
  type        = "zip"
}

resource "aws_lambda_function" "Function3" {
  function_name                  = "Function3"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_Function3.output_path
  handler                        = "worker.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.Function3_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_Function3.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                      = "Function3"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "Table3"
      AWS_SQS_QUEUE_NAME_0      = "Queue4"
    }
  }
  tags = {
    Name           = "Function3"
    State          = "Mix-Inline-and-Identity-Policy"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_Function3_st_Mix-Inline-and-Identity-Policy_attach]
}
