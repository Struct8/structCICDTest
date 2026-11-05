data "aws_iam_policy_document" "api-regular-logs_doc" {
  statement {
    sid       = "AllowLogapiregular"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log-api-regular.arn}:*"]
  }
}

resource "aws_iam_policy" "api-regular-logs" {
  name        = "api-regular-logs"
  description = "Access Policy api-regular-logs"
  policy      = data.aws_iam_policy_document.api-regular-logs_doc.json
}

data "aws_iam_policy_document" "edge-abtest-logs_doc" {
  statement {
    sid       = "AllowLogedgeabtest"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log-edge-abtest.arn}:*"]
  }
}

resource "aws_iam_policy" "edge-abtest-logs" {
  name        = "edge-abtest-logs"
  description = "Access Policy edge-abtest-logs"
  policy      = data.aws_iam_policy_document.edge-abtest-logs_doc.json
}

data "aws_iam_policy_document" "edge-auth-logs_doc" {
  statement {
    sid       = "AllowLogedgeauth"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log-edge-auth.arn}:*"]
  }
}

resource "aws_iam_policy" "edge-auth-logs" {
  name        = "edge-auth-logs"
  description = "Access Policy edge-auth-logs"
  policy      = data.aws_iam_policy_document.edge-auth-logs_doc.json
}

data "aws_iam_policy_document" "edge-headers-logs_doc" {
  statement {
    sid       = "AllowLogedgeheaders"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log-edge-headers.arn}:*"]
  }
}

resource "aws_iam_policy" "edge-headers-logs" {
  name        = "edge-headers-logs"
  description = "Access Policy edge-headers-logs"
  policy      = data.aws_iam_policy_document.edge-headers-logs_doc.json
}

data "aws_iam_policy_document" "edge-rewrite-logs_doc" {
  statement {
    sid       = "AllowLogedgerewrite"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log-edge-rewrite.arn}:*"]
  }
}

resource "aws_iam_policy" "edge-rewrite-logs" {
  name        = "edge-rewrite-logs"
  description = "Access Policy edge-rewrite-logs"
  policy      = data.aws_iam_policy_document.edge-rewrite-logs_doc.json
}

data "aws_iam_policy_document" "lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1_doc" {
  statement {
    sid       = "AllowReadParam"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.CloudFrontOutputs.arn]
  }
  statement {
    sid       = "AllowReadParam1"
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.cf-signing-private-key.arn]
  }
  statement {
    sid       = "AllowSecureStringDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["ssm.*.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}

resource "aws_iam_policy" "lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1" {
  name        = "lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1"
  description = "Access Policy for api-regular-nonedge"
  policy      = data.aws_iam_policy_document.lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1_doc.json
}

resource "aws_iam_role" "api-regular-nonedge_role" {
  name = "api-regular-nonedge_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "api-regular-nonedge_role"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "edge-abtest-viewer-response_role" {
  name = "edge-abtest-viewer-response_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "edge-abtest-viewer-response_role"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "edge-auth-viewer-request_role" {
  name = "edge-auth-viewer-request_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "edge-auth-viewer-request_role"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "edge-rewrite-origin-request_role" {
  name = "edge-rewrite-origin-request_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "edge-rewrite-origin-request_role"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "edge-security-headers-origin-response_role" {
  name = "edge-security-headers-origin-response_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "edge-security-headers-origin-response_role"
    State          = "Public-and-signed-URL-delivery-on-CloudFront1"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "api-regular-logs_attach_api-regular-nonedge_role" {
  policy_arn = aws_iam_policy.api-regular-logs.arn
  role       = aws_iam_role.api-regular-nonedge_role.name
}

resource "aws_iam_role_policy_attachment" "edge-abtest-logs_attach_edge-abtest-viewer-response_role" {
  policy_arn = aws_iam_policy.edge-abtest-logs.arn
  role       = aws_iam_role.edge-abtest-viewer-response_role.name
}

resource "aws_iam_role_policy_attachment" "edge-auth-logs_attach_edge-auth-viewer-request_role" {
  policy_arn = aws_iam_policy.edge-auth-logs.arn
  role       = aws_iam_role.edge-auth-viewer-request_role.name
}

resource "aws_iam_role_policy_attachment" "edge-headers-logs_attach_edge-security-headers-origin-response_role" {
  policy_arn = aws_iam_policy.edge-headers-logs.arn
  role       = aws_iam_role.edge-security-headers-origin-response_role.name
}

resource "aws_iam_role_policy_attachment" "edge-rewrite-logs_attach_edge-rewrite-origin-request_role" {
  policy_arn = aws_iam_policy.edge-rewrite-logs.arn
  role       = aws_iam_role.edge-rewrite-origin-request_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1_attach" {
  policy_arn = aws_iam_policy.lambda_function_api-regular-nonedge_st_Public-and-signed-URL-delivery-on-CloudFront1.arn
  role       = aws_iam_role.api-regular-nonedge_role.name
}
