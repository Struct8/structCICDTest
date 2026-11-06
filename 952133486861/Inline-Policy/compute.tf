data "archive_file" "archive_struct8-templates_Function2" {
  output_path = "${path.module}/struct8-templates_Function2.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/lambda-showcase/v1/lambda/worker"
  type        = "zip"
}

resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_Function2.output_path
  handler                        = "worker.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.Function2_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_Function2.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                      = "Function2"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "Table2"
      AWS_SQS_QUEUE_NAME_0      = "Queue3"
    }
  }
  tags = {
    Name           = "Function2"
    State          = "Inline-Policy"
    Struct8Creator = "rmay struct"
  }
}
