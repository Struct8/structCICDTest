resource "aws_s3_bucket" "origem-cf-validacao" {
  bucket              = "origem-cf-validacao"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "origem-cf-validacao"
    State          = "Public-and-signed-URL-delivery-on-CloudFront2"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "origem-cf-validacao_controls" {
  bucket = aws_s3_bucket.origem-cf-validacao.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_origem-cf-validacao_st_Public-and-signed-URL-delivery-on-CloudFront2_doc" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origem-cf-validacao.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn-aberta.id}"]
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
    resources = ["${aws_s3_bucket.origem-cf-validacao.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.cdn-protegida.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_origem-cf-validacao_st_Public-and-signed-URL-delivery-on-CloudFront2" {
  bucket = aws_s3_bucket.origem-cf-validacao.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_origem-cf-validacao_st_Public-and-signed-URL-delivery-on-CloudFront2_doc.json
}

resource "aws_s3_bucket_public_access_block" "origem-cf-validacao_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.origem-cf-validacao.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "origem-cf-validacao_configuration" {
  bucket = aws_s3_bucket.origem-cf-validacao.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "origem-cf-validacao_versioning" {
  bucket = aws_s3_bucket.origem-cf-validacao.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_object" "index-html2" {
  acl          = "private"
  bucket       = aws_s3_bucket.origem-cf-validacao.bucket
  content      = "<!doctype html><meta charset=\"utf-8\"><title>Struct8 CloudFront</title><h1>CloudFront servindo do S3</h1><p>Se voce esta lendo isto pelo dominio do CloudFront, o Origin Access Control, a distribution e a policy de cache subiram e funcionam.</p>"
  content_type = "text/html"
  key          = "index.html"
  tags = {
    Name           = "index-html2"
    State          = "Public-and-signed-URL-delivery-on-CloudFront2"
    Struct8Creator = "rmay struct"
  }
}
