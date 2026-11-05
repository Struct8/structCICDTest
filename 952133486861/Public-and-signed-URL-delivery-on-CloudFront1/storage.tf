resource "aws_s3_bucket" "origin-cf-validation" {
  bucket              = "origem-cf-validacao"
  force_destroy       = true
  object_lock_enabled = false
  tags = {
    Name           = "origin-cf-validation"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "origin-cf-validation_controls" {
  bucket = aws_s3_bucket.origin-cf-validation.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_origin-cf-validation_st_Public-and-signed-URL-delivery-on-CloudFront1_doc" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin-cf-validation.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn-open.id}"]
    }
  }
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly1"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin-cf-validation.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn-protected.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_origin-cf-validation_st_Public-and-signed-URL-delivery-on-CloudFront1" {
  bucket = aws_s3_bucket.origin-cf-validation.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_origin-cf-validation_st_Public-and-signed-URL-delivery-on-CloudFront1_doc.json
}

resource "aws_s3_bucket_public_access_block" "origin-cf-validation_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.origin-cf-validation.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "origin-cf-validation_configuration" {
  bucket = aws_s3_bucket.origin-cf-validation.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "origin-cf-validation_versioning" {
  bucket = aws_s3_bucket.origin-cf-validation.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_object" "img-private-1" {
  source       = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/private/photo-1.svg"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content_type = "image/svg+xml"
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/private/photo-1.svg")
  key          = "private/photo-1.svg"
  tags = {
    Name           = "img-private-1"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "img-public-1" {
  source       = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/public/photo-1.svg"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content_type = "image/svg+xml"
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/public/photo-1.svg")
  key          = "public/photo-1.svg"
  tags = {
    Name           = "img-public-1"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "index-html2" {
  acl          = "private"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content      = "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>Struct8 CloudFront</title></head><body><h1>CloudFront serving from S3</h1><p>If you are reading this through the CloudFront domain, the Origin Access Control, the distribution and the cache policy are deployed and working.</p></body></html>"
  content_type = "text/html"
  key          = "index.html"
  tags = {
    Name           = "index-html2"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "lab-app-js" {
  source       = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/app.js"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/app.js")
  key          = "lab/app.js"
  tags = {
    Name           = "lab-app-js"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "lab-index-html" {
  source       = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/index.html"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content_type = "text/html"
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/index.html")
  key          = "lab/index.html"
  tags = {
    Name           = "lab-index-html"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "lab-styles-css" {
  source       = "${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/styles.css"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content_type = "text/css"
  etag         = filemd5("${path.module}/.external_modules/struct8-templates/templates/cloudfront-lambda-edge-showcase/v1/lab/styles.css")
  key          = "lab/styles.css"
  tags = {
    Name           = "lab-styles-css"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "premium-secret-html" {
  acl          = "private"
  bucket       = aws_s3_bucket.origin-cf-validation.bucket
  content      = "<!doctype html><meta charset=utf-8><title>Premium</title><h1>Signed-URL protected content</h1><p>You presented a valid signed URL. Direct access to /premium without a signature returns 403.</p>"
  content_type = "text/html"
  key          = "premium/secret.html"
  tags = {
    Name           = "premium-secret-html"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}
