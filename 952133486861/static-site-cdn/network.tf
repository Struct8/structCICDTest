resource "aws_cloudfront_distribution" "site-cdn1" {
  comment             = "Static website CDN over HTTPS. Root index.html, managed caching, 403/404 -> /error.html. Region ca-central-1."
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
    target_origin_id       = "site-origin1"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
  }
  origin {
    domain_name              = aws_s3_bucket.static-site-web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_static-site-web.id
    origin_id                = "site-origin1"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "site-cdn1"
    State          = "static-site-cdn"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_control" "oac_static-site-web" {
  name                              = "oac-static-site-web"
  description                       = "OAC for static-site-web"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
