resource "aws_lambda_function" "Function1" {
  function_name                  = "Function1"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "worker.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.Function1_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
      ACCOUNT                   = "952133486861"
      AWS_DYNAMODB_TABLE_NAME_0 = "Table1"
      AWS_SQS_QUEUE_NAME_0      = "Queue2"
      NAME                      = "Function1"
      REGION                    = "us-west-2"
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
    Name           = "Function1"
    State          = "Identity-Policy"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_Function1_st_Identity-Policy_attach]
}
