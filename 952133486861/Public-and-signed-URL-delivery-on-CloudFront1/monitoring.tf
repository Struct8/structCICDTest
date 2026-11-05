resource "aws_cloudwatch_log_group" "log-api-regular" {
  name              = "/aws/lambda/api-regular-nonedge"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "log-api-regular"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "log-edge-abtest" {
  name              = "/aws/lambda/edge-abtest-viewer-response"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "log-edge-abtest"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "log-edge-auth" {
  name              = "/aws/lambda/edge-auth-viewer-request"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "log-edge-auth"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "log-edge-headers" {
  name              = "/aws/lambda/edge-security-headers-origin-response"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "log-edge-headers"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "log-edge-rewrite" {
  name              = "/aws/lambda/edge-rewrite-origin-request"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "log-edge-rewrite"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}
