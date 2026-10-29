terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/presign_c/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_policy" "lambda_function_presign_st_s3-presigned-upload" {
  name        = "lambda_function_presign_st_s3-presigned-upload"
  description = "Access Policy for presign"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.uploads.arn}/*"
      ],
      "Sid": "PresignedObjectAccess"
    }
  ]
})
}

resource "aws_iam_role" "presign_role" {
  name                  = "presign_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "presign_role"
    State          = "s3-presigned-upload"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_presign_st_s3-presigned-upload_attach_presign_role" {
  policy_arn = aws_iam_policy.lambda_function_presign_st_s3-presigned-upload.arn
  role       = aws_iam_role.presign_role.name
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "uploads" {
  bucket              = "s3-presign-uploads-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  object_lock_enabled = false
  tags = {
    Name           = "uploads"
    State          = "s3-presigned-upload"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_cors_configuration" "uploads_cors" {
  bucket = aws_s3_bucket.uploads.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 300
  }
}

resource "aws_s3_bucket_ownership_controls" "uploads_controls" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.uploads.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_configuration" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads_versioning" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_lambda_function" "presign" {
  function_name                  = "presign"
  architectures                  = ["arm64"]
  description                    = "Presigned-URL generator. nodejs22.x arm64, 128MB"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.presign_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT                        = "952133486861"
    AWS_LAMBDA_FUNCTION_URL_NAME_0 = "presign-url1"
    AWS_S3_BUCKET_NAME_0           = "s3-presign-uploads-952133486861-us-west-2-an"
    BUCKET_NAME                    = "s3-presign-uploads-952133486861-us-west-2-an"
    NAME                           = "presign"
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
    Name           = "presign"
    State          = "s3-presigned-upload"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_presign_st_s3-presigned-upload_attach_presign_role]
}

resource "aws_lambda_function_url" "presign" {
  function_name      = aws_lambda_function.presign.function_name
  authorization_type = "NONE"
  cors {
    allow_headers = ["content-type"]
    allow_methods = ["GET", "POST"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign_to_presign" {
  function_name          = aws_lambda_function.presign.function_name
  statement_id           = "perm_aws_lambda_function_url_presign-url1_to_presigned56ce021a2fd37e41e4ef066f"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.presign]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign_to_presign_invoke" {
  function_name            = aws_lambda_function.presign.function_name
  statement_id             = "perm_aws_lambda_function_url_presign-url1_to_presign_invoke100b091cbcc3f324e2586cdbff"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.presign, aws_lambda_permission.perm_aws_lambda_function_url_presign_to_presign]
}


