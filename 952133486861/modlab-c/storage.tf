resource "aws_s3_bucket" "modlab-c-balde" {
  bucket              = "modlab-c-balde-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "modlab-c-balde"
    State          = "modlab-c"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "modlab-c-balde_controls" {
  bucket = aws_s3_bucket.modlab-c-balde.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "modlab-c-balde_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.modlab-c-balde.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "modlab-c-balde_configuration" {
  bucket = aws_s3_bucket.modlab-c-balde.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "modlab-c-balde_versioning" {
  bucket = aws_s3_bucket.modlab-c-balde.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
