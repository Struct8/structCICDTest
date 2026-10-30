terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/s3-secure-baseline/main.tfstate"
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

### CATEGORY: STORAGE ###

resource "aws_s3_bucket" "secure-baseline-bucket" {
  bucket              = "secure-baseline-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "secure-baseline-bucket"
    State          = "s3-secure-baseline"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "secure-baseline-bucket_lifecycle" {
  bucket = aws_s3_bucket.secure-baseline-bucket.id
  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  rule {
    id     = "transition-to-cheaper-storage"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
  rule {
    id     = "expire-temp-objects"
    status = "Enabled"
    expiration {
      days = 7
    }
    filter {
      prefix = "tmp/"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "secure-baseline-bucket_controls" {
  bucket = aws_s3_bucket.secure-baseline-bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "secure-baseline-bucket_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.secure-baseline-bucket.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure-baseline-bucket_configuration" {
  bucket = aws_s3_bucket.secure-baseline-bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "secure-baseline-bucket_versioning" {
  bucket = aws_s3_bucket.secure-baseline-bucket.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}


