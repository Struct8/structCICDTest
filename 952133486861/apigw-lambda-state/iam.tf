data "aws_iam_policy_document" "lambda_function_demo-handler_st_apigw-lambda-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-handler-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-handler_st_apigw-lambda-state" {
  name        = "lambda_function_demo-handler_st_apigw-lambda-state"
  description = "Access Policy for demo-handler"
  policy      = data.aws_iam_policy_document.lambda_function_demo-handler_st_apigw-lambda-state_doc.json
}

data "aws_iam_policy_document" "doc_perm_role_apigw_demo-restapi_to_assets" {
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.assets.arn]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.assets.arn}/*"]
  }
}

data "aws_iam_policy_document" "doc_perm_role_apigw_demo-restapi_to_events" {
  statement {
    sid       = "AllowKinesisStreamAccess"
    effect    = "Allow"
    actions   = ["kinesis:PutRecord"]
    resources = [aws_kinesis_stream.events.arn]
  }
}

data "aws_iam_policy_document" "doc_perm_role_apigw_demo-restapi_to_items" {
  statement {
    sid       = "AllowDynamoDBCRUD"
    effect    = "Allow"
    actions   = ["dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem"]
    resources = [aws_dynamodb_table.items.arn, "${aws_dynamodb_table.items.arn}/*"]
  }
}

data "aws_iam_policy_document" "doc_perm_role_apigw_demo-restapi_to_jobs" {
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.jobs.arn]
  }
}

data "aws_iam_policy_document" "doc_trust_role_apigw_demo-restapi_to_assets" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "doc_trust_role_apigw_demo-restapi_to_events" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "doc_trust_role_apigw_demo-restapi_to_items" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "doc_trust_role_apigw_demo-restapi_to_jobs" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["apigateway.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "demo-handler_role" {
  name = "demo-handler_role"
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
    Name           = "demo-handler_role"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_apigw_demo-restapi_to_assets" {
  name               = "api-demo-restapi-assets-role"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_apigw_demo-restapi_to_assets.json
}

resource "aws_iam_role" "role_apigw_demo-restapi_to_events" {
  name               = "api-demo-restapi-events-role"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_apigw_demo-restapi_to_events.json
}

resource "aws_iam_role" "role_apigw_demo-restapi_to_items" {
  name               = "api-demo-restapi-items-role"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_apigw_demo-restapi_to_items.json
}

resource "aws_iam_role" "role_apigw_demo-restapi_to_jobs" {
  name               = "api-demo-restapi-jobs-role"
  assume_role_policy = data.aws_iam_policy_document.doc_trust_role_apigw_demo-restapi_to_jobs.json
}

resource "aws_iam_role_policy" "policy_role_apigw_demo-restapi_to_assets" {
  name   = "access-assets"
  policy = data.aws_iam_policy_document.doc_perm_role_apigw_demo-restapi_to_assets.json
  role   = aws_iam_role.role_apigw_demo-restapi_to_assets.id
}

resource "aws_iam_role_policy" "policy_role_apigw_demo-restapi_to_events" {
  name   = "access-events"
  policy = data.aws_iam_policy_document.doc_perm_role_apigw_demo-restapi_to_events.json
  role   = aws_iam_role.role_apigw_demo-restapi_to_events.id
}

resource "aws_iam_role_policy" "policy_role_apigw_demo-restapi_to_items" {
  name   = "access-items"
  policy = data.aws_iam_policy_document.doc_perm_role_apigw_demo-restapi_to_items.json
  role   = aws_iam_role.role_apigw_demo-restapi_to_items.id
}

resource "aws_iam_role_policy" "policy_role_apigw_demo-restapi_to_jobs" {
  name   = "access-jobs"
  policy = data.aws_iam_policy_document.doc_perm_role_apigw_demo-restapi_to_jobs.json
  role   = aws_iam_role.role_apigw_demo-restapi_to_jobs.id
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-handler_st_apigw-lambda-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-handler_st_apigw-lambda-state.arn
  role       = aws_iam_role.demo-handler_role.name
}

resource "aws_acm_certificate" "api-cert" {
  domain_name       = "api.cloudman.pro"
  key_algorithm     = "RSA_2048"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = {
    Name           = "api-cert"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_acm_certificate_validation" "Validation_api-cert" {
  certificate_arn         = aws_acm_certificate.api-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.Route53_Record_api-cert_api_cloudman_pro : record.fqdn]
}
