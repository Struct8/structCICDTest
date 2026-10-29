terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/s3-presigned-upload/main.tfstate"
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

data "aws_iam_policy_document" "lambda_function_presign_st_s3-presigned-upload_doc" {
  statement {
    sid       = "PresignedObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.uploads.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_presign_st_s3-presigned-upload" {
  name        = "lambda_function_presign_st_s3-presigned-upload"
  description = "Access Policy for presign"
  policy      = data.aws_iam_policy_document.lambda_function_presign_st_s3-presigned-upload_doc.json
}

resource "aws_iam_role" "presign_role" {
  name = "presign_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "presign_role"
    State          = "s3-presigned-upload"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_presign_st_s3-presigned-upload_attach" {
  policy_arn = aws_iam_policy.lambda_function_presign_st_s3-presigned-upload.arn
  role       = aws_iam_role.presign_role.name
}




### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "uploads" {
  bucket              = "s3-presign-uploads-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
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
    allowed_methods = ["PUT", "GET"]
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

data "archive_file" "archive_struct8-templates_presign" {
  output_path = "${path.module}/struct8-templates_presign.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/s3-presigned-upload/v1/lambda/presign"
  type        = "zip"
}

resource "aws_lambda_function" "presign" {
  function_name                  = "presign"
  architectures                  = ["arm64"]
  description                    = "Presigned-URL generator. nodejs22.x arm64, 128MB"
  filename                       = data.archive_file.archive_struct8-templates_presign.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.presign_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_presign.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
    BUCKET_NAME                    = aws_s3_bucket.uploads.id
    NAME                           = "presign"
    REGION                         = data.aws_region.current.region
    ACCOUNT                        = data.aws_caller_identity.current.account_id
    AWS_LAMBDA_FUNCTION_URL_NAME_0 = "presign-url1"
    AWS_S3_BUCKET_NAME_0           = "s3-presign-uploads-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  }
  }
  tags = {
    Name           = "presign"
    State          = "s3-presigned-upload"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_presign_st_s3-presigned-upload_attach]
}

resource "aws_lambda_function_url" "presign-url1" {
  function_name      = aws_lambda_function.presign.function_name
  authorization_type = "NONE"
  cors {
    allow_headers = ["content-type"]
    allow_methods = ["GET", "POST"]
    allow_origins = ["*"]
    max_age       = 300
  }
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign-url1_to_presign" {
  function_name          = aws_lambda_function.presign.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_presign-url1_to_presign"
  depends_on             = [aws_lambda_function_url.presign-url1]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_presign-url1_to_presign_invoke" {
  function_name            = aws_lambda_function.presign.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_presign-url1_to_presign_invoke"
  depends_on               = [aws_lambda_function_url.presign-url1, aws_lambda_permission.perm_aws_lambda_function_url_presign-url1_to_presign]
}


