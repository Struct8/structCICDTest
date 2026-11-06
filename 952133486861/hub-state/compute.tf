data "archive_file" "archive_struct8-hub_hub-fn" {
  output_path = "${path.module}/struct8-hub_hub-fn.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "hub-fn" {
  function_name                  = "hub-fn"
  architectures                  = ["arm64"]
  description                    = "Lambda running the same Struct8 Hub code as the container. It receives the scheduled event and forwards it to the resources connected to it."
  filename                       = data.archive_file.archive_struct8-hub_hub-fn.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.hub-fn_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_hub-fn.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME    = "hub-fn"
      REGION  = data.aws_region.current.region
      ACCOUNT = data.aws_caller_identity.current.account_id
    }
  }
  tags = {
    Name           = "hub-fn"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_hub-fn_st_hub-state_attach]
}
