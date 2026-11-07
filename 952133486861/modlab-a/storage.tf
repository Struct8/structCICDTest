resource "aws_s3_bucket" "source" {
  bucket              = "modlab-a-source-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "source"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_notification" "source-events" {
  bucket      = aws_s3_bucket.source.id
  eventbridge = true
  lambda_function {
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".csv"
    lambda_function_arn = aws_lambda_function.processor.arn
  }
  queue {
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
    queue_arn     = aws_sqs_queue.archive.arn
  }
  topic {
    events    = ["s3:ObjectRemoved:*"]
    topic_arn = aws_sns_topic.alerts.arn
  }
  depends_on = [aws_lambda_permission.perm_aws_s3_bucket_source_to_processor, aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a, aws_sns_topic_policy.aws_sns_topic_policy_alerts_st_modlab-a]
}

resource "aws_s3_bucket_ownership_controls" "source_controls" {
  bucket = aws_s3_bucket.source.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "source_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.source.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_configuration" {
  bucket = aws_s3_bucket.source.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
