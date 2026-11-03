resource "aws_s3_bucket" "data" {
  bucket              = "s3-cost-opt-data-952133486861-us-east-1-an"
  bucket_namespace    = "account-regional"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "data"
    State          = "s3-cost-optimization"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket" "reports" {
  bucket              = "s3-cost-opt-reports-952133486861-us-east-1-an"
  bucket_namespace    = "account-regional"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "reports"
    State          = "s3-cost-optimization"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_analytics_configuration" "data-analytics" {
  name   = "data-analytics"
  bucket = aws_s3_bucket.data.id
  storage_class_analysis {
    data_export {
      output_schema_version = "V_1"
      destination {
        s3_bucket_destination {
          bucket_arn = aws_s3_bucket.reports.arn
          format     = "CSV"
        }
      }
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "data-tiering" {
  name   = "data-tiering"
  bucket = aws_s3_bucket.data.id
  status = "Enabled"
  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

resource "aws_s3_bucket_inventory" "data-inventory" {
  name                     = "data-inventory"
  bucket                   = aws_s3_bucket.data.id
  enabled                  = true
  included_object_versions = "Current"
  destination {
    bucket {
      bucket_arn = aws_s3_bucket.reports.arn
      format     = "CSV"
    }
  }
  schedule {
    frequency = "Daily"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lifecycle" {
  bucket                                 = aws_s3_bucket.data.id
  transition_default_minimum_object_size = "all_storage_classes_128K"
  rule {
    id     = "tier-down-by-age"
    status = "Enabled"
    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }
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
    id     = "expire-old-versions"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  rule {
    id     = "expire-temp"
    status = "Enabled"
    expiration {
      days                         = 7
      expired_object_delete_marker = false
    }
    filter {
      prefix = "tmp/"
    }
  }
}

resource "aws_s3_bucket_metric" "data-metrics" {
  name   = "data-metrics"
  bucket = aws_s3_bucket.data.id
}

resource "aws_s3_bucket_ownership_controls" "data_controls" {
  bucket = aws_s3_bucket.data.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "reports_controls" {
  bucket = aws_s3_bucket.reports.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "data_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.data.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "reports_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.reports.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_configuration" {
  bucket = aws_s3_bucket.data.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reports_configuration" {
  bucket = aws_s3_bucket.reports.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "reports_versioning" {
  bucket = aws_s3_bucket.reports.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
