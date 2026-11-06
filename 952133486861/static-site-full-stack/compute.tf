data "archive_file" "archive_struct8-templates_presign-url-generator" {
  output_path = "${path.module}/struct8-templates_presign-url-generator.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/s3-presigned-upload/v1/lambda/presign"
  type        = "zip"
}

resource "aws_lambda_function" "presign-url-generator" {
  function_name                  = "presign-url-generator"
  architectures                  = ["arm64"]
  description                    = "Lambda function that generates presigned PUT URLs for S3 uploads. Node.js 22.x, ARM64, 128MB, 10s timeout. "
  filename                       = data.archive_file.archive_struct8-templates_presign-url-generator.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.presign-url-generator_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_presign-url-generator.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      BUCKET_NAME                    = aws_s3_bucket.site-uploads.id
      NAME                           = "presign-url-generator"
      REGION                         = data.aws_region.current.region
      ACCOUNT                        = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0           = "s3-presign-uploads-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "presign-url"
    }
  }
  tags = {
    Name           = "presign-url-generator"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_presign-url-generator_st_static-site-full-stack_attach]
}

resource "aws_lambda_function_url" "presign-url" {
  function_name      = aws_lambda_function.presign-url-generator.function_name
  authorization_type = "NONE"
  cors {
    allow_headers = ["content-type"]
    allow_methods = ["GET", "POST"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign-url_to_presign-url-generator" {
  function_name          = aws_lambda_function.presign-url-generator.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_presign-url_to_presign-url-generator"
  depends_on             = [aws_lambda_function_url.presign-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign-url_to_presign-url-generator_invoke" {
  function_name            = aws_lambda_function.presign-url-generator.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_presign-url_to_presign-url-generator_invoke"
  depends_on               = [aws_lambda_function_url.presign-url, aws_lambda_permission.perm_aws_lambda_function_url_presign-url_to_presign-url-generator]
}
