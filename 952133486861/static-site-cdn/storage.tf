resource "aws_s3_bucket" "static-site-web" {
  bucket              = "static-site-cacentral1-952133486861-8f3a2c"
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Name           = "static-site-web"
    State          = "static-site-cdn"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_bucket_ownership_controls" "static-site-web_controls" {
  bucket = aws_s3_bucket.static-site-web.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

data "aws_iam_policy_document" "aws_s3_bucket_policy_static-site-web_st_static-site-cdn_doc" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static-site-web.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.site-cdn1.id}"]
    }
  }
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy_static-site-web_st_static-site-cdn" {
  bucket = aws_s3_bucket.static-site-web.id
  policy = data.aws_iam_policy_document.aws_s3_bucket_policy_static-site-web_st_static-site-cdn_doc.json
}

resource "aws_s3_bucket_public_access_block" "static-site-web_block" {
  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.static-site-web.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static-site-web_configuration" {
  bucket = aws_s3_bucket.static-site-web.id
  rule {
    blocked_encryption_types = ["SSE-C"]
    bucket_key_enabled       = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "static-site-web_versioning" {
  bucket = aws_s3_bucket.static-site-web.id
  versioning_configuration {
    mfa_delete = "Disabled"
    status     = "Suspended"
  }
}

resource "aws_s3_object" "error-html1" {
  acl    = "private"
  bucket = aws_s3_bucket.static-site-web.bucket
  content = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Page not found</title>
  <style>
    body { font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif; background:#0f172a; color:#e2e8f0; min-height:100vh; display:flex; align-items:center; justify-content:center; text-align:center; padding:24px; margin:0; }
    h1 { font-size:64px; margin:0 0 8px; color:#38bdf8; }
    p { color:#94a3b8; font-size:18px; }
    a { color:#38bdf8; text-decoration:none; }
  </style>
</head>
<body>
  <div>
    <h1>404</h1>
    <p>The page you are looking for does not exist.</p>
    <p><a href="/">Back to home</a></p>
  </div>
</body>
</html>
  EOF
  content_type = "text/html"
  key          = "error.html"
  lifecycle {
    ignore_changes = [acl, content]
  }
  tags = {
    Name           = "error-html1"
    State          = "static-site-cdn"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_s3_object" "index-html2" {
  acl    = "private"
  bucket = aws_s3_bucket.static-site-web.bucket
  content = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My Static Site</title>
  <style>
    :root { --bg:#0f172a; --card:#1e293b; --accent:#38bdf8; --text:#e2e8f0; --muted:#94a3b8; }
    * { box-sizing:border-box; margin:0; padding:0; }
    body { font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; align-items:center; justify-content:center; padding:24px; }
    .card { background:var(--card); border-radius:16px; padding:48px 40px; max-width:640px; width:100%; box-shadow:0 20px 60px rgba(0,0,0,.4); }
    .badge { display:inline-block; background:rgba(56,189,248,.15); color:var(--accent); font-size:12px; font-weight:600; letter-spacing:.08em; text-transform:uppercase; padding:6px 12px; border-radius:999px; margin-bottom:20px; }
    h1 { font-size:32px; line-height:1.2; margin-bottom:12px; }
    p { color:var(--muted); font-size:16px; line-height:1.6; margin-bottom:24px; }
    .grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-top:8px; }
    .item { background:rgba(148,163,184,.08); border:1px solid rgba(148,163,184,.12); border-radius:10px; padding:16px; }
    .item h3 { font-size:14px; color:var(--accent); margin-bottom:6px; }
    .item span { font-size:13px; color:var(--muted); }
    footer { margin-top:28px; font-size:13px; color:var(--muted); text-align:center; }
  </style>
</head>
<body>
  <div class="card">
    <span class="badge">Online</span>
    <h1>Static site is live</h1>
    <p>This page is hosted in an Amazon S3 bucket and delivered globally through the Amazon CloudFront CDN, with HTTPS and edge caching.</p>
    <div class="grid">
      <div class="item"><h3>Storage</h3><span>Amazon S3</span></div>
      <div class="item"><h3>CDN</h3><span>Amazon CloudFront</span></div>
      <div class="item"><h3>Region</h3><span>ca-central-1</span></div>
      <div class="item"><h3>Provisioning</h3><span>Terraform</span></div>
    </div>
    <footer>Provisioned with Struct8 &middot; Infrastructure as code</footer>
  </div>
</body>
</html>
  EOF
  content_type = "text/html"
  key          = "index.html"
  lifecycle {
    ignore_changes = [acl, content]
  }
  tags = {
    Name           = "index-html2"
    State          = "static-site-cdn"
    Struct8Creator = "rmay struct"
  }
}
