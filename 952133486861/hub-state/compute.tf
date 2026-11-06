resource "aws_lambda_function" "hub-fn" {
  function_name                  = "hub-fn"
  architectures                  = ["arm64"]
  description                    = "Lambda running the same Struct8 Hub code as the container. It receives the scheduled event and forwards it to the resources connected to it."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.hub-fn_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
      ACCOUNT = "952133486861"
      NAME    = "hub-fn"
      REGION  = "us-west-2"
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
    Name           = "hub-fn"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_hub-fn_st_hub-state_attach]
}
