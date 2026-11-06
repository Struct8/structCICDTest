resource "aws_cloudfront_distribution" "site-cdn" {
  comment             = "Static website from S3; /api/* goes to a Lambda that returns presigned S3 upload URLs. HTTPS only."
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 404
    response_page_path    = "/error.html"
  }
  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id       = "site-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    cache_policy_id          = data.aws_cloudfront_cache_policy.policy_cachingdisabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.policy_allviewerexcepthostheader.id
    target_origin_id         = "api-origin"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    path_pattern             = "/api/*"
    viewer_protocol_policy   = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.path-rewrite-api-to-origin.arn
    }
  }
  origin {
    domain_name              = aws_s3_bucket.site-assets.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_site-assets.id
    origin_id                = "site-origin"
  }
  origin {
    domain_name = trimsuffix(trimprefix(aws_lambda_function_url.presign-url.function_url, "https://"), "/")
    origin_id   = "api-origin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "site-cdn"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_function" "path-rewrite-api-to-origin" {
  name = "path-rewrite-api-to-origin"
  code = <<-EOF
function handler(event) {
  var request = event.request;
  var uri = request.uri;
  
  // Remove /api prefix from the path
  if (uri.startsWith('/api')) {
    request.uri = uri.substring(4);
    // If empty after removing /api, set to root
    if (request.uri === '') {
      request.uri = '/';
    }
  }
  
  return request;
}
EOF
  comment = "Rewrites /api/* paths by removing /api prefix before forwarding to Lambda Function URL"
  publish = true
  runtime = "cloudfront-js-2.0"
  tags = {
    Name           = "path-rewrite-api-to-origin"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_site-assets" {
  name                              = "oac-site-assets"
  description                       = "OAC for site-assets"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
