resource "aws_s3_bucket" "codebuild-lab-artifacts" {
  bucket              = "codebuild-lab-artifacts-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "codebuild-lab-artifacts"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket" "codebuild-lab-cache" {
  bucket              = "codebuild-lab-cache-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "codebuild-lab-cache"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "codebuild-lab-artifacts_controls" {
  bucket = aws_s3_bucket.codebuild-lab-artifacts.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "codebuild-lab-cache_controls" {
  bucket = aws_s3_bucket.codebuild-lab-cache.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "codebuild-lab-artifacts_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.codebuild-lab-artifacts.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "codebuild-lab-cache_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.codebuild-lab-cache.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codebuild-lab-artifacts_configuration" {
  bucket = aws_s3_bucket.codebuild-lab-artifacts.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "codebuild-lab-cache_configuration" {
  bucket = aws_s3_bucket.codebuild-lab-cache.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "codebuild-lab-artifacts_versioning" {
  bucket = aws_s3_bucket.codebuild-lab-artifacts.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_bucket_versioning" "codebuild-lab-cache_versioning" {
  bucket = aws_s3_bucket.codebuild-lab-cache.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
