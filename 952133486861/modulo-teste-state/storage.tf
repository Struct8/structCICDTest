resource "aws_s3_bucket" "arquivos" {
  bucket              = "arquivos-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "arquivos"
    State          = "modulo-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "arquivos_controls" {
  bucket = aws_s3_bucket.arquivos.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "arquivos_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.arquivos.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "arquivos_configuration" {
  bucket = aws_s3_bucket.arquivos.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "arquivos_versioning" {
  bucket = aws_s3_bucket.arquivos.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
