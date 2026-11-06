resource "aws_s3_bucket" "hub-demo" {
  bucket              = "hub-demo-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "hub-demo"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "hub-demo_controls" {
  bucket = aws_s3_bucket.hub-demo.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "hub-demo_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.hub-demo.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "hub-demo_configuration" {
  bucket = aws_s3_bucket.hub-demo.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "hub-demo_versioning" {
  bucket = aws_s3_bucket.hub-demo.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
