resource "aws_s3_bucket" "policy-bucket" {
  bucket              = "policy-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "policy-bucket"
    State          = "Resource-Based-Policy"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_notification" "Notification" {
  bucket = aws_s3_bucket.policy-bucket.id
  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = aws_sqs_queue.Queue1.arn
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_Queue1_st_Resource-Based-Policy]
}

resource "aws_s3_bucket_ownership_controls" "policy-bucket_controls" {
  bucket = aws_s3_bucket.policy-bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "policy-bucket_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.policy-bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "policy-bucket_configuration" {
  bucket = aws_s3_bucket.policy-bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "policy-bucket_versioning" {
  bucket = aws_s3_bucket.policy-bucket.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
