resource "aws_apigatewayv2_api" "http-api-regular" {
  name          = "http-api-regular"
  description   = "HTTP API v2 exposed via CloudFront under /api. AWS_PROXY integration with the regular Lambda; catch-all proxy route on the default stage with auto_deploy."
  protocol_type = "HTTP"
  tags = {
    Name           = "http-api-regular"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_apigatewayv2_integration" "integration-lambda-regular" {
  api_id                 = aws_apigatewayv2_api.http-api-regular.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.api-regular-nonedge.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 30000
  depends_on             = [aws_lambda_permission.perm_aws_apigatewayv2_api_http-api-regular_to_api-regular-nonedge]
}

resource "aws_apigatewayv2_route" "route-api-proxy" {
  api_id    = aws_apigatewayv2_api.http-api-regular.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integration-lambda-regular.id}"
}

resource "aws_apigatewayv2_stage" "stage-default" {
  api_id      = aws_apigatewayv2_api.http-api-regular.id
  name        = "$default"
  auto_deploy = true
  default_route_settings {
    data_trace_enabled       = false
    detailed_metrics_enabled = false
    throttling_burst_limit   = 0
    throttling_rate_limit    = 0
  }
  tags = {
    Name           = "stage-default"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_cache_policy" "cache-validation" {
  name    = "cache-validation"
  comment = "Cache policy propria, para validar o fio contra a managed"
  min_ttl = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "cdn-open" {
  comment             = "Open CDN (no auth): signed-URL base, no edge functions. Cache policies + CloudFront Function backed by KVS."
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "origin-open"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id            = aws_cloudfront_cache_policy.cache-validation.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin-request-validation.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.headers-validation.id
    target_origin_id           = "origin-open"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = false
    default_ttl                = 0
    max_ttl                    = 0
    min_ttl                    = 0
    path_pattern               = "/route-api/*"
    smooth_streaming           = false
    viewer_protocol_policy     = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer-request-kvs.arn
    }
    grpc_config {
      enabled = false
    }
  }
  origin {
    domain_name                 = aws_s3_bucket.origin-cf-validation.bucket_regional_domain_name
    origin_access_control_id    = aws_cloudfront_origin_access_control.oac_origin-cf-validation.id
    origin_id                   = "origin-open"
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "cdn-open"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_distribution" "cdn-protected" {
  comment             = "Protected CDN: lab + public/private galleries, /api, 4 Lambda@Edge, signed cookies/URLs, FLE."
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "origin-protected"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-rewrite-origin-request.qualified_arn
    }
    lambda_function_association {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-security-headers-origin-response.qualified_arn
    }
    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-auth-viewer-request.qualified_arn
    }
    lambda_function_association {
      event_type   = "viewer-response"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-abtest-viewer-response.qualified_arn
    }
  }
  ordered_cache_behavior {
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    target_origin_id       = "origin-api-gateway"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/api/*"
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    target_origin_id       = "origin-protected"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/lab/*"
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
    lambda_function_association {
      event_type   = "origin-request"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-rewrite-origin-request.qualified_arn
    }
    lambda_function_association {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-security-headers-origin-response.qualified_arn
    }
    lambda_function_association {
      event_type   = "viewer-response"
      include_body = false
      lambda_arn   = aws_lambda_function.edge-abtest-viewer-response.qualified_arn
    }
  }
  ordered_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "origin-protected"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/premium/*"
    smooth_streaming       = false
    trusted_key_groups     = [aws_cloudfront_key_group.subscribers-group.id]
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "origin-protected"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/public/*"
    smooth_streaming       = false
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    target_origin_id       = "origin-protected"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "/private/*"
    smooth_streaming       = false
    trusted_key_groups     = [aws_cloudfront_key_group.subscribers-group-cookies.id]
    viewer_protocol_policy = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  origin {
    domain_name                 = "${aws_apigatewayv2_api.http-api-regular.id}.execute-api.${data.aws_region.current.region}.amazonaws.com"
    origin_id                   = "origin-api-gateway"
    response_completion_timeout = 0
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    domain_name                 = aws_s3_bucket.origin-cf-validation.bucket_regional_domain_name
    origin_access_control_id    = aws_cloudfront_origin_access_control.oac_origin-cf-validation.id
    origin_id                   = "origin-protected"
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "cdn-protected"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_field_level_encryption_config" "card-encryption" {
  content_type_profile_config {
    forward_when_content_type_is_unknown = true
    content_type_profiles {
      items {
        profile_id   = aws_cloudfront_field_level_encryption_profile.card-profile.id
        content_type = "application/x-www-form-urlencoded"
        format       = "URLEncoded"
      }
    }
  }
  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = true
  }
}

resource "aws_cloudfront_field_level_encryption_profile" "card-profile" {
  name = "card-profile"
  encryption_entities {
    items {
      provider_id   = "cloudman-fle-provider"
      public_key_id = aws_cloudfront_public_key.signing-key.id
      field_patterns {
        items = ["credit-card-*"]
      }
    }
  }
}

resource "aws_cloudfront_function" "viewer-request-kvs" {
  name = "viewer-request-kvs"
  code = <<-EOF
import cf from 'cloudfront';
const kvs = cf.kvs();

async function handler(event) {
    const request = event.request;
    let banner = 'sem-kvs';
    try {
        banner = await kvs.get('banner');
    } catch (e) {
        banner = 'chave-ausente';
    }
    request.headers['x-struct8-banner'] = { value: banner };
    return request;
}
EOF
  comment                      = "Le uma chave do Key Value Store e devolve no header"
  key_value_store_associations = [aws_cloudfront_key_value_store.kvs-validation.arn]
  publish                      = true
  runtime                      = "cloudfront-js-2.0"
  tags = {
    Name           = "viewer-request-kvs"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_key_group" "subscribers-group" {
  name  = "subscribers-group"
  items = [aws_cloudfront_public_key.signing-key.id]
}

resource "aws_cloudfront_key_group" "subscribers-group-cookies" {
  name  = "subscribers-group-cookies"
  items = [aws_cloudfront_public_key.signing-key-cookies.id]
}

resource "aws_cloudfront_key_value_store" "kvs-validation" {
  name = "kvs-validation"
}

resource "aws_cloudfront_origin_access_control" "oac_origin-cf-validation" {
  name                              = "oac-origin-cf-validation"
  description                       = "OAC for origin-cf-validation"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_request_policy" "origin-request-validation" {
  name = "origin-request-validation"
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_public_key" "signing-key" {
  name    = "signing-key"
  comment = "Disposable demo key (no private half). Used by field-level encryption and the /premium signed-URL key group."
  encoded_key = <<-EOF
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAl8Q8aW6nki9vHic8OcLx
oh4PKEmqPZHejyd1PfrIdVn12PW+XpOdSNC3izm8sDBVrv2Bs3hQKBKGW0YRn/8Z
QTpYEM3hucp2qcAIRX90NK7VZNp3roNrEc1fqexBiAWmMfVrzSfw9Aa/zZJ+SFiJ
bPtG1jVwOo1bUaWOIsgY5Rlk63FBt2yQZivbgpHJWgxdzsZsE4hbXAyODrKdylU4
9psTspDqHLwM/JKaRrlkGxPh2xN5FY2dxhpn2nHY+tFsWIushmqQtwKUNhDhhfKi
oPf55edG1QFEzyjzm21jz5J9um+ph3F8I/2wPXPzGS5G5yu6O5yz4R3T+2huYcGr
LQIDAQAB
-----END PUBLIC KEY-----
EOF
}

resource "aws_cloudfront_public_key" "signing-key-cookies" {
  name    = "signing-key-cookies"
  comment = "Signed-cookie public key for /private; its id is the cookie Key-Pair-Id."
  encoded_key = <<-EOF
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqaq7WRyC/XwxVPT1STyZ
6jWUSz9AALkDxQD8xb6eV+69Udc+X3VR5IM1Tg6i3Q24b7Jq0P2Xzn7oJ7mphrW/
XWc6pDqW9atOKxt9y1g02wmedhlHrgTToqeb9oAikGwgOGe2X8ZMRPFESiOzkZW/
s7ell7GJOXZ+M8G7fbI07xEDsEAKJ00DtsPTN6zuEVfs4H+ay08/aDKoS6qHQKpM
mtZ0EaVi8vQZelHCxilsnwD/or+0EYMO2tEoUMUrtbJ3dJja6koB4DkbJ4i3Dt02
ySXjhIA180u8ZblHMOpLB/gn5bfvr2sM5ASDCqb5gv4MV2CjB4e9j00lmxSav7cG
wQIDAQAB
-----END PUBLIC KEY-----
EOF
}

resource "aws_cloudfront_response_headers_policy" "headers-validation" {
  name = "headers-validation"
  cors_config {
    access_control_allow_credentials = false
    access_control_max_age_sec       = 600
    origin_override                  = true
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS"]
    }
    access_control_allow_origins {
      items = ["*"]
    }
  }
  security_headers_config {
    content_security_policy {
      content_security_policy = "default-src 'self'"
      override                = true
    }
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
    referrer_policy {
      override        = true
      referrer_policy = "strict-origin-when-cross-origin"
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = false
    }
    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
  server_timing_headers_config {
    enabled       = true
    sampling_rate = 10
  }
}

resource "aws_cloudfrontkeyvaluestore_key" "banner" {
  key                 = "banner"
  key_value_store_arn = aws_cloudfront_key_value_store.kvs-validation.arn
  value               = "struct8-validacao"
}
