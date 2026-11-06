resource "aws_lambda_function" "presign-url-generator" {
  function_name                  = "presign-url-generator"
  architectures                  = ["arm64"]
  description                    = "Lambda function that generates presigned PUT URLs for S3 uploads. Node.js 22.x, ARM64, 128MB, 10s timeout. "
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.presign-url-generator_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT                        = "952133486861"
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "presign-url"
      AWS_S3_BUCKET_NAME_0           = "s3-presign-uploads-952133486861-us-west-2-an"
      BUCKET_NAME                    = "s3-presign-uploads-952133486861-us-west-2-an"
      NAME                           = "presign-url-generator"
      REGION                         = "us-west-2"
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
  statement_id           = "perm_aws_lambda_function_url_presign-url_to_presign-url-generator0bad48e0414af30d10598e4d92"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.presign-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign-url_to_presign-url-generator_invoke" {
  function_name            = aws_lambda_function.presign-url-generator.function_name
  statement_id             = "perm_aws_lambda_function_url_presign-url_to_presign-url-generator_invoke3afd4826dd89be9cc560544ed2"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.presign-url, aws_lambda_permission.perm_aws_lambda_function_url_presign-url_to_presign-url-generator]
}
