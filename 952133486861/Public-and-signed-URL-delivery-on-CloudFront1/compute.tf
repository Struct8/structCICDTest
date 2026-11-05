data "archive_file" "archive_struct8-templates_api-regular-nonedge" {
  output_path = "${path.module}/struct8-templates_api-regular-nonedge.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/functions/api-regular"
  type        = "zip"
}

resource "aws_lambda_function" "api-regular-nonedge" {
  function_name                  = "api-regular-nonedge"
  architectures                  = ["arm64"]
  description                    = "REGULAR (non-edge) Lambda for contrast: no region restriction, accepts env vars, larger timeout. Lightweight backend example."
  filename                       = data.archive_file.archive_struct8-templates_api-regular-nonedge.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.api-regular-nonedge_role.arn
  runtime                        = "nodejs20.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_api-regular-nonedge.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      PRIVATE_KEY_PARAM             = "/cloudfront-lab/signing-private-key"
      CF_OUTPUTS_PARAM              = "/cloudfront-lab/cf-outputs"
      GREETING_NAME                 = "world"
      NAME                          = "api-regular-nonedge"
      REGION                        = data.aws_region.current.region
      ACCOUNT                       = data.aws_caller_identity.current.account_id
      AWS_SSM_PARAMETER_NAME_0      = "cf-signing-private-key"
      AWS_SSM_PARAMETER_NAME_ENVVAR = "CloudFrontOutputs"
    }
  }
  tags = {
    Name           = "api-regular-nonedge"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1_attach, aws_iam_role_policy_attachment.api-regular-logs_attach_api-regular-nonedge_role]
}

data "archive_file" "archive_struct8-templates_edge-abtest-viewer-response" {
  output_path = "${path.module}/struct8-templates_edge-abtest-viewer-response.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/edge/abtest-viewer-response"
  type        = "zip"
}

resource "aws_lambda_function" "edge-abtest-viewer-response" {
  function_name                  = "edge-abtest-viewer-response"
  architectures                  = ["x86_64"]
  description                    = "Lambda@Edge (viewer-response): A/B testing / per-device cookie on the response to the viewer."
  filename                       = data.archive_file.archive_struct8-templates_edge-abtest-viewer-response.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.edge-abtest-viewer-response_role.arn
  runtime                        = "nodejs20.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_edge-abtest-viewer-response.output_base64sha256
  timeout                        = 5
  tags = {
    Name           = "edge-abtest-viewer-response"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.edge-abtest-logs_attach_edge-abtest-viewer-response_role]
}

data "archive_file" "archive_struct8-templates_edge-auth-viewer-request" {
  output_path = "${path.module}/struct8-templates_edge-auth-viewer-request.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/edge/auth-viewer-request"
  type        = "zip"
}

resource "aws_lambda_function" "edge-auth-viewer-request" {
  function_name                  = "edge-auth-viewer-request"
  architectures                  = ["x86_64"]
  description                    = "Lambda@Edge (viewer-request): authentication/authorization at the edge before serving. Edge requires us-east-1, a published version, and no env vars."
  filename                       = data.archive_file.archive_struct8-templates_edge-auth-viewer-request.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.edge-auth-viewer-request_role.arn
  runtime                        = "nodejs20.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_edge-auth-viewer-request.output_base64sha256
  timeout                        = 5
  tags = {
    Name           = "edge-auth-viewer-request"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.edge-auth-logs_attach_edge-auth-viewer-request_role]
}

data "archive_file" "archive_struct8-templates_edge-rewrite-origin-request" {
  output_path = "${path.module}/struct8-templates_edge-rewrite-origin-request.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/edge/rewrite-origin-request"
  type        = "zip"
}

resource "aws_lambda_function" "edge-rewrite-origin-request" {
  function_name                  = "edge-rewrite-origin-request"
  architectures                  = ["x86_64"]
  description                    = "Lambda@Edge (origin-request): URL rewrite / SPA routing before reaching the origin."
  filename                       = data.archive_file.archive_struct8-templates_edge-rewrite-origin-request.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.edge-rewrite-origin-request_role.arn
  runtime                        = "nodejs20.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_edge-rewrite-origin-request.output_base64sha256
  timeout                        = 5
  tags = {
    Name           = "edge-rewrite-origin-request"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.edge-rewrite-logs_attach_edge-rewrite-origin-request_role]
}

data "archive_file" "archive_struct8-templates_edge-security-headers-origin-response" {
  output_path = "${path.module}/struct8-templates_edge-security-headers-origin-response.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/edge/security-headers-origin-response"
  type        = "zip"
}

resource "aws_lambda_function" "edge-security-headers-origin-response" {
  function_name                  = "edge-security-headers-origin-response"
  architectures                  = ["x86_64"]
  description                    = "Lambda@Edge (origin-response): injects security headers (HSTS, CSP). Cheaper alternative: aws_cloudfront_response_headers_policy."
  filename                       = data.archive_file.archive_struct8-templates_edge-security-headers-origin-response.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.edge-security-headers-origin-response_role.arn
  runtime                        = "nodejs20.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_edge-security-headers-origin-response.output_base64sha256
  timeout                        = 5
  ephemeral_storage {
    size = 512
  }
  tags = {
    Name           = "edge-security-headers-origin-response"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.edge-headers-logs_attach_edge-security-headers-origin-response_role]
}

resource "aws_lambda_permission" "perm_aws_apigatewayv2_api_http-api-regular_to_api-regular-nonedge" {
  function_name       = aws_lambda_function.api-regular-nonedge.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_apigatewayv2_api.http-api-regular.execution_arn}/*/*"
  statement_id_prefix = "perm_aws_apigatewayv2_api_http-api-regular_to_api-regular-nonedge"
}
