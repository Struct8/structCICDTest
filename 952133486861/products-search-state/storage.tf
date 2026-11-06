resource "aws_s3_bucket" "static-site" {
  bucket              = "static-site-952133486861-us-west-2-an"
  bucket_namespace    = "account-regional"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "static-site"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_cors_configuration" "static-site_cors" {
  bucket = aws_s3_bucket.static-site.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = ["https://hardstore.cloudman.pro"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_ownership_controls" "static-site_controls" {
  bucket = aws_s3_bucket.static-site.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_static-site_st_products-search-state_doc" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static-site.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.site-cdn.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_static-site_st_products-search-state" {
  bucket = aws_s3_bucket.static-site.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_static-site_st_products-search-state_doc.json
}

resource "aws_s3_bucket_public_access_block" "static-site_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.static-site.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static-site_configuration" {
  bucket = aws_s3_bucket.static-site.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "static-site_versioning" {
  bucket = aws_s3_bucket.static-site.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_object" "site-files_admin_html" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "text/html; charset=utf-8"
  key          = "admin.html"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_gpu_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/gpu.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_keyboard_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/keyboard.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_laptop_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/laptop.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_monitor_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/monitor.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_mouse_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/mouse.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_img_seed_storage_svg" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "image/svg+xml"
  key          = "img/seed/storage.svg"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "site-files_index_html" {
  bucket       = aws_s3_bucket.static-site.bucket
  content_type = "text/html; charset=utf-8"
  key          = "index.html"
  tags = {
    Name           = "site-files"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}
