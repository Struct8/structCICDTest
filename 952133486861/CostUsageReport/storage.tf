resource "aws_s3_bucket" "your-bucket-cost-usage-report" {
  bucket              = "struct8-lab-cur-952133486861-usw2"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Struct8Management = "Struct8CUR"
    Name              = "your-bucket-cost-usage-report"
    State             = "CostUsageReport"
    Struct8Creator    = "rmay struct"
  }
}

resource "aws_s3_bucket_notification" "CURNotification" {
  bucket = aws_s3_bucket.your-bucket-cost-usage-report.id
  lambda_function {
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "cur-reports/"
    filter_suffix       = ".json"
    lambda_function_arn = aws_lambda_function.ProcessCUR.arn
  }
  depends_on = [aws_lambda_permission.perm_aws_s3_bucket_your-bucket-cost-usage-report_to_ProcessCUR]
}

resource "aws_s3_bucket_ownership_controls" "your-bucket-cost-usage-report_controls" {
  bucket = aws_s3_bucket.your-bucket-cost-usage-report.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_your-bucket-cost-usage-report_st_CostUsageReport_doc" {
  statement {
    sid    = "AllowObjectCRUD"
    effect = "Allow"
    principals {
      identifiers = ["billingreports.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetBucketAcl", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.your-bucket-cost-usage-report.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowObjectCRUD1"
    effect = "Allow"
    principals {
      identifiers = ["billingreports.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.your-bucket-cost-usage-report.arn}/*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_your-bucket-cost-usage-report_st_CostUsageReport" {
  bucket = aws_s3_bucket.your-bucket-cost-usage-report.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_your-bucket-cost-usage-report_st_CostUsageReport_doc.json
}

resource "aws_s3_bucket_public_access_block" "your-bucket-cost-usage-report_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.your-bucket-cost-usage-report.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "your-bucket-cost-usage-report_configuration" {
  bucket = aws_s3_bucket.your-bucket-cost-usage-report.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "your-bucket-cost-usage-report_versioning" {
  bucket = aws_s3_bucket.your-bucket-cost-usage-report.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}
