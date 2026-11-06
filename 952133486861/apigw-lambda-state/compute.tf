data "archive_file" "archive_struct8-hub_demo-handler" {
  output_path = "${path.module}/struct8-hub_demo-handler.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "demo-handler" {
  function_name                  = "demo-handler"
  architectures                  = ["arm64"]
  description                    = "API backend Lambda. Code comes from the public struct8-hub repo, prebuilt folder (runtime nodejs22.x, handler index.handler). Handles requests routed to /demo-handler."
  filename                       = data.archive_file.archive_struct8-hub_demo-handler.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-handler_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_demo-handler.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME    = "demo-handler"
      REGION  = data.aws_region.current.region
      ACCOUNT = data.aws_caller_identity.current.account_id
    }
  }
  tags = {
    Name           = "demo-handler"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-handler_st_apigw-lambda-state_attach]
}

resource "aws_lambda_permission" "perm_aws_api_gateway_rest_api_demo-restapi_to_demo-handler_openapi" {
  function_name       = aws_lambda_function.demo-handler.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_api_gateway_rest_api.demo-restapi.execution_arn}/*/*/demo-handler"
  statement_id_prefix = "perm_aws_api_gateway_rest_api_demo-restapi_to_demo-handler_openapi"
}
