resource "aws_s3_bucket" "uploads-bucket" {
  bucket              = "uploads-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "uploads-bucket"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_notification" "uploads-to-eventbridge" {
  bucket      = aws_s3_bucket.uploads-bucket.id
  eventbridge = true
}

resource "aws_s3_bucket_ownership_controls" "uploads-bucket_controls" {
  bucket = aws_s3_bucket.uploads-bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "uploads-bucket_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.uploads-bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads-bucket_configuration" {
  bucket = aws_s3_bucket.uploads-bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads-bucket_versioning" {
  bucket = aws_s3_bucket.uploads-bucket.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
