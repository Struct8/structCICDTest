data "aws_iam_policy_document" "lambda_function_lambda-ingestion_st_products-search-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.ingestion-logs.arn}:*"]
  }
  statement {
    sid       = "DataApi"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.products-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessproductsaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.products-aurora.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.ingestion-queue.arn]
  }
}

resource "aws_iam_policy" "lambda_function_lambda-ingestion_st_products-search-state" {
  name        = "lambda_function_lambda-ingestion_st_products-search-state"
  description = "Access Policy for lambda-ingestion"
  policy      = data.aws_iam_policy_document.lambda_function_lambda-ingestion_st_products-search-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_lambda-init-db_st_products-search-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.init-db-logs.arn}:*"]
  }
  statement {
    sid       = "DataApi"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.products-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessproductsaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.products-aurora.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "lambda_function_lambda-init-db_st_products-search-state" {
  name        = "lambda_function_lambda-init-db_st_products-search-state"
  description = "Access Policy for lambda-init-db"
  policy      = data.aws_iam_policy_document.lambda_function_lambda-init-db_st_products-search-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_lambda-presign_st_products-search-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.presign-logs.arn}:*"]
  }
  statement {
    sid       = "AllowImagePut"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.static-site.arn}/img/*"]
  }
}

resource "aws_iam_policy" "lambda_function_lambda-presign_st_products-search-state" {
  name        = "lambda_function_lambda-presign_st_products-search-state"
  description = "Access Policy for lambda-presign"
  policy      = data.aws_iam_policy_document.lambda_function_lambda-presign_st_products-search-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_lambda-publisher_st_products-search-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.publisher-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.ingestion-queue.arn]
  }
}

resource "aws_iam_policy" "lambda_function_lambda-publisher_st_products-search-state" {
  name        = "lambda_function_lambda-publisher_st_products-search-state"
  description = "Access Policy for lambda-publisher"
  policy      = data.aws_iam_policy_document.lambda_function_lambda-publisher_st_products-search-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_lambda-search_st_products-search-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.search-logs.arn}:*"]
  }
  statement {
    sid       = "DataApi"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.products-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessproductsaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.products-aurora.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "lambda_function_lambda-search_st_products-search-state" {
  name        = "lambda_function_lambda-search_st_products-search-state"
  description = "Access Policy for lambda-search"
  policy      = data.aws_iam_policy_document.lambda_function_lambda-search_st_products-search-state_doc.json
}

resource "aws_iam_role" "lambda-ingestion_role" {
  name = "lambda-ingestion_role"
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
    Name           = "lambda-ingestion_role"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "lambda-init-db_role" {
  name = "lambda-init-db_role"
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
    Name           = "lambda-init-db_role"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "lambda-presign_role" {
  name = "lambda-presign_role"
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
    Name           = "lambda-presign_role"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "lambda-publisher_role" {
  name = "lambda-publisher_role"
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
    Name           = "lambda-publisher_role"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "lambda-search_role" {
  name = "lambda-search_role"
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
    Name           = "lambda-search_role"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_lambda-ingestion_st_products-search-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_lambda-ingestion_st_products-search-state.arn
  role       = aws_iam_role.lambda-ingestion_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_lambda-init-db_st_products-search-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_lambda-init-db_st_products-search-state.arn
  role       = aws_iam_role.lambda-init-db_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_lambda-presign_st_products-search-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_lambda-presign_st_products-search-state.arn
  role       = aws_iam_role.lambda-presign_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_lambda-publisher_st_products-search-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_lambda-publisher_st_products-search-state.arn
  role       = aws_iam_role.lambda-publisher_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_lambda-search_st_products-search-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_lambda-search_st_products-search-state.arn
  role       = aws_iam_role.lambda-search_role.name
}

resource "aws_acm_certificate" "hardstore-cert" {
  domain_name       = "hardstore.cloudman.pro"
  key_algorithm     = "RSA_2048"
  region            = "us-east-1"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags = {
    Name           = "hardstore-cert"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_acm_certificate_validation" "Validation_hardstore-cert" {
  certificate_arn         = aws_acm_certificate.hardstore-cert.arn
  region                  = "us-east-1"
  validation_record_fqdns = [for record in aws_route53_record.Route53_Record_hardstore-cert_hardstore_cloudman_pro : record.fqdn]
}
