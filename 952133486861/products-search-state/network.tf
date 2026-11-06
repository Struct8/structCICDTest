resource "aws_vpc" "products-vpc" {
  cidr_block           = "10.7.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "products-vpc"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id                              = aws_vpc.products-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.7.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-a"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id                              = aws_vpc.products-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.7.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-b"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route53_record" "Route53_Record_hardstore-cert_hardstore_cloudman_pro" {
  for_each = {
    for dvo in aws_acm_certificate.hardstore-cert.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "hardstore.cloudman.pro"
  }
  name            = each.value.resource_record_name
  zone_id         = data.aws_route53_zone.cloudman-zone.zone_id
  allow_overwrite = true
  records         = [each.value.resource_record_value]
  ttl             = 300
  type            = each.value.resource_record_type
}

resource "aws_route53_record" "alias_a_aws_cloudfront_distribution_site-cdn_hardstore_cloudman_pro" {
  name    = "hardstore.cloudman.pro"
  zone_id = data.aws_route53_zone.cloudman-zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.site-cdn.domain_name
    zone_id                = aws_cloudfront_distribution.site-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa_aws_cloudfront_distribution_site-cdn_hardstore_cloudman_pro" {
  name    = "hardstore.cloudman.pro"
  zone_id = data.aws_route53_zone.cloudman-zone.zone_id
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.site-cdn.domain_name
    zone_id                = aws_cloudfront_distribution.site-cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "rds_cluster_products-aurora_group" {
  name                   = "rds_cluster_products-aurora_group"
  vpc_id                 = aws_vpc.products-vpc.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "rds_cluster_products-aurora_group"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_rds_cluster_products_aurora_group_egress_all_protocols" {
  security_group_id = aws_security_group.rds_cluster_products-aurora_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_apigatewayv2_api" "products-http-api" {
  name          = "products-http-api"
  description   = "HTTP API de busca e detalhe de produtos"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_headers     = ["content-type"]
    allow_methods     = ["GET", "OPTIONS", "POST"]
    allow_origins     = ["*"]
    max_age           = 0
  }
  tags = {
    Name           = "products-http-api"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_apigatewayv2_integration" "products-integration" {
  api_id                 = aws_apigatewayv2_api.products-http-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda-publisher.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 10000
  depends_on             = [aws_lambda_permission.perm_aws_apigatewayv2_api_products-http-api_to_lambda-publisher]
}

resource "aws_apigatewayv2_integration" "search-integration" {
  api_id                 = aws_apigatewayv2_api.products-http-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda-search.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000
  depends_on             = [aws_lambda_permission.perm_aws_apigatewayv2_api_products-http-api_to_lambda-search]
}

resource "aws_apigatewayv2_integration" "upload-integration" {
  api_id                 = aws_apigatewayv2_api.products-http-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.lambda-presign.invoke_arn
  payload_format_version = "2.0"
  timeout_milliseconds   = 10000
  depends_on             = [aws_lambda_permission.perm_aws_apigatewayv2_api_products-http-api_to_lambda-presign]
}

resource "aws_apigatewayv2_route" "products-route" {
  api_id    = aws_apigatewayv2_api.products-http-api.id
  route_key = "POST /produtos"
  target    = "integrations/${aws_apigatewayv2_integration.products-integration.id}"
}

resource "aws_apigatewayv2_route" "search-route" {
  api_id    = aws_apigatewayv2_api.products-http-api.id
  route_key = "GET /busca"
  target    = "integrations/${aws_apigatewayv2_integration.search-integration.id}"
}

resource "aws_apigatewayv2_route" "upload-route" {
  api_id    = aws_apigatewayv2_api.products-http-api.id
  route_key = "GET /upload-url"
  target    = "integrations/${aws_apigatewayv2_integration.upload-integration.id}"
}

resource "aws_apigatewayv2_stage" "default-stage" {
  api_id      = aws_apigatewayv2_api.products-http-api.id
  name        = "$default"
  auto_deploy = true
  default_route_settings {
    data_trace_enabled       = false
    detailed_metrics_enabled = false
    throttling_burst_limit   = 0
    throttling_rate_limit    = 0
  }
  tags = {
    Name           = "default-stage"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudfront_distribution" "site-cdn" {
  aliases             = ["hardstore.cloudman.pro"]
  comment             = "CDN do site de busca de produtos"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  default_cache_behavior {
    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    target_origin_id         = "site-origin"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD", "OPTIONS"]
    viewer_protocol_policy   = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    target_origin_id         = "api-origin"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = false
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    path_pattern             = "/busca*"
    smooth_streaming         = false
    viewer_protocol_policy   = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    target_origin_id         = "api-origin"
    allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = false
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    path_pattern             = "/produtos*"
    smooth_streaming         = false
    viewer_protocol_policy   = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  ordered_cache_behavior {
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    target_origin_id         = "api-origin"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    compress                 = false
    default_ttl              = 0
    max_ttl                  = 0
    min_ttl                  = 0
    path_pattern             = "/upload-url*"
    smooth_streaming         = false
    viewer_protocol_policy   = "redirect-to-https"
    grpc_config {
      enabled = false
    }
  }
  origin {
    domain_name                 = "${aws_apigatewayv2_api.products-http-api.id}.execute-api.${data.aws_region.current.region}.amazonaws.com"
    origin_id                   = "api-origin"
    response_completion_timeout = 0
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  origin {
    domain_name                 = aws_s3_bucket.static-site.bucket_regional_domain_name
    origin_access_control_id    = aws_cloudfront_origin_access_control.oac_static-site.id
    origin_id                   = "site-origin"
    response_completion_timeout = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = {
    Name           = "site-cdn"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.Validation_hardstore-cert.certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "oac_static-site" {
  name                              = "oac-static-site"
  description                       = "OAC for static-site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
