variable "processor_arn" {
  type = any
}

variable "alerts_arn" {
  type = any
}

variable "perm_aws_s3_bucket_source_to_processor_id" {
  type    = any
  default = null
}

variable "aws_sns_topic_policy_alerts_st_modlab_a_id" {
  type    = any
  default = null
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

resource "aws_sqs_queue" "archive" {
  name                              = "archive"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 60
  tags = {
    Name           = "archive"
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
    lambda_function_arn = var.processor_arn
  }
  queue {
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".jpg"
    queue_arn     = aws_sqs_queue.archive.arn
  }
  topic {
    events    = ["s3:ObjectRemoved:*"]
    topic_arn = var.alerts_arn
  }
  depends_on = [var.perm_aws_s3_bucket_source_to_processor_id, aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a, var.aws_sns_topic_policy_alerts_st_modlab_a_id]
}

resource "aws_s3_bucket_versioning" "source_versioning" {
  bucket = aws_s3_bucket.source.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
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

resource "aws_s3_bucket_ownership_controls" "source_controls" {
  bucket = aws_s3_bucket.source.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_archive_st_modlab-a_doc" {
  statement {
    sid    = "AllowS3SendMessage"
    effect = "Allow"
    principals {
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.archive.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.archive.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_archive_st_modlab-a" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_archive_st_modlab-a_doc.json
  queue_url = aws_sqs_queue.archive.id
}

output "source_arn" {
  value = aws_s3_bucket.source.arn
}

output "archive_arn" {
  value = aws_sqs_queue.archive.arn
}

output "aws_sqs_queue_policy_archive_st_modlab_a_id" {
  value = aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a.id
}
