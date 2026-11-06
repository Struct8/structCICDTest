resource "aws_lambda_function" "Function2" {
  function_name                  = "Function2"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "worker.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.Function2_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "Table2"
      AWS_SQS_QUEUE_NAME_0      = "Queue3"
      NAME                      = "Function2"
      REGION                    = data.aws_region.current.region
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
    Name           = "Function2"
    State          = "Inline-Policy"
    Struct8Creator = "rmay struct"
  }
}
