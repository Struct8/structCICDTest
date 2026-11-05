resource "aws_s3_bucket" "flowlogs-bucket" {
  bucket              = "flowlogs-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "flowlogs-bucket"
    State          = "Prometheus"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "flowlogs-bucket_lifecycle" {
  bucket = aws_s3_bucket.flowlogs-bucket.id
  rule {
    id     = "expire-logs"
    status = "Enabled"
    expiration {
      days                         = 1
      expired_object_delete_marker = false
    }
  }
}

resource "aws_s3_bucket_notification" "Notification" {
  bucket = aws_s3_bucket.flowlogs-bucket.id
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log.gz"
    lambda_function_arn = aws_lambda_function.process-flow-logs.arn
  }
  depends_on = [aws_lambda_permission.perm_aws_s3_bucket_flowlogs-bucket_to_process-flow-logs]
}

resource "aws_s3_bucket_ownership_controls" "flowlogs-bucket_controls" {
  bucket = aws_s3_bucket.flowlogs-bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "flowlogs-bucket_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.flowlogs-bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flowlogs-bucket_configuration" {
  bucket = aws_s3_bucket.flowlogs-bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "flowlogs-bucket_versioning" {
  bucket = aws_s3_bucket.flowlogs-bucket.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
