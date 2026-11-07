data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_sqs_queue" "modlab-c-fila" {
  name                              = "modlab-c-fila"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "modlab-c-fila"
    State          = "modlab-c"
    Struct8Creator = "rmay struct"
  }
}

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

resource "aws_s3_bucket_versioning" "modlab-c-balde_versioning" {
  bucket = aws_s3_bucket.modlab-c-balde.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
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

resource "aws_s3_bucket_ownership_controls" "modlab-c-balde_controls" {
  bucket = aws_s3_bucket.modlab-c-balde.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_modlab-c-fila_st_modlab-c_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.modlab-c-fila.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_modlab-c-fila_st_modlab-c" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c_doc.json
  queue_url = aws_sqs_queue.modlab-c-fila.id
}

output "modlab_c_fila_arn" {
  value = aws_sqs_queue.modlab-c-fila.arn
}

output "aws_sqs_queue_policy_modlab_c_fila_st_modlab_c_whole" {
  value = aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
}
