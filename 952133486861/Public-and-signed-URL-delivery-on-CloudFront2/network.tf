resource "aws_cloudfront_cache_policy" "cache-validacao" {
  name    = "cache-validacao"
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

resource "aws_cloudfront_distribution" "cdn-aberta" {
  comment             = "Valida o caminho aberto: responde ao curl sem assinatura"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    target_origin_id       = "origin-aberta"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    cache_policy_id            = aws_cloudfront_cache_policy.cache-validacao.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.origin-request-validacao.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.headers-validacao.id
    target_origin_id           = "origin-aberta"
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    path_pattern               = "/rota-api/*"
    viewer_protocol_policy     = "redirect-to-https"
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.viewer-request-kvs1.arn
    }
  }
  origin {
    domain_name              = aws_s3_bucket.origem-cf-validacao.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_origem-cf-validacao.id
    origin_id                = "origin-aberta"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "cdn-aberta"
    State          = "Public-and-signed-URL-delivery-on-CloudFront2"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_distribution" "cdn-protegida" {
  comment             = "Valida URL assinada e cifra de campo: responde 403 sem assinatura"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id           = data.aws_cloudfront_cache_policy.policy_cachingoptimized.id
    field_level_encryption_id = aws_cloudfront_field_level_encryption_config.cifra-cartao.id
    target_origin_id          = "origin-protegida"
    allowed_methods           = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods            = ["GET", "HEAD", "OPTIONS"]
    trusted_key_groups        = [aws_cloudfront_key_group.grupo-assinantes.id]
    viewer_protocol_policy    = "redirect-to-https"
  }
  origin {
    domain_name              = aws_s3_bucket.origem-cf-validacao.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac_origem-cf-validacao.id
    origin_id                = "origin-protegida"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "cdn-protegida"
    State          = "Public-and-signed-URL-delivery-on-CloudFront2"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_field_level_encryption_config" "cifra-cartao" {
  content_type_profile_config {
    forward_when_content_type_is_unknown = true
    content_type_profiles {
      items {
        profile_id   = aws_cloudfront_field_level_encryption_profile.perfil-cartao.id
        content_type = "application/x-www-form-urlencoded"
        format       = "URLEncoded"
      }
    }
  }
  query_arg_profile_config {
    forward_when_query_arg_profile_is_unknown = true
  }
}

resource "aws_cloudfront_field_level_encryption_profile" "perfil-cartao" {
  name = "perfil-cartao"
  encryption_entities {
    items {
      provider_id   = "cloudman-fle-provider"
      public_key_id = aws_cloudfront_public_key.chave-assinatura.id
      field_patterns {
        items = ["credit-card-*"]
      }
    }
  }
}

resource "aws_cloudfront_function" "viewer-request-kvs1" {
  name = "viewer-request-kvs1"
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
  key_value_store_associations = [aws_cloudfront_key_value_store.kvs-validacao.arn]
  publish                      = true
  runtime                      = "cloudfront-js-2.0"
}

resource "aws_cloudfront_key_group" "grupo-assinantes" {
  name  = "grupo-assinantes"
  items = [aws_cloudfront_public_key.chave-assinatura.id]
}

resource "aws_cloudfront_key_value_store" "kvs-validacao" {
  name = "kvs-validacao"
}

resource "aws_cloudfront_origin_access_control" "oac_origem-cf-validacao" {
  name                              = "oac-origem-cf-validacao"
  description                       = "OAC for origem-cf-validacao"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_request_policy" "origin-request-validacao" {
  name = "origin-request-validacao"
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

resource "aws_cloudfront_public_key" "chave-assinatura" {
  name    = "chave-assinatura"
  comment = "Chave RSA de descarte: a privada nao existe em lugar nenhum"
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

resource "aws_cloudfront_response_headers_policy" "headers-validacao" {
  name = "headers-validacao"
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

resource "aws_cloudfrontkeyvaluestore_key" "banner1" {
  key                 = "banner"
  key_value_store_arn = aws_cloudfront_key_value_store.kvs-validacao.arn
  value               = "struct8-validacao"
}
