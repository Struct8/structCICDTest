variable "lambda_function_order_release_st_modlab_b_doc_extra_statements_json" {
  type = any
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "archive_file" "archive_struct8-templates_order-charge" {
  output_path = "${path.root}/struct8-templates_order-charge.zip"
  source_dir  = "${path.root}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-charge"
  type        = "zip"
}

resource "aws_lambda_function" "order-charge" {
  function_name                  = "order-charge"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-charge.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-charge_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-charge.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                  = "order-charge"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-charge"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-charge_st_modlab-b_attach]
}

data "archive_file" "archive_struct8-templates_order-release" {
  output_path = "${path.root}/struct8-templates_order-release.zip"
  source_dir  = "${path.root}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-release"
  type        = "zip"
}

resource "aws_lambda_function" "order-release" {
  function_name                  = "order-release"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-release.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-release_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-release.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                      = "order-release"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
      AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-release"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-release_st_modlab-b_attach]
}

resource "aws_cloudwatch_log_group" "order-charge-logs" {
  name              = "/aws/lambda/order-charge"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-charge-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-release-logs" {
  name              = "/aws/lambda/order-release"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "order-release-logs"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-charge_role" {
  name = "order-charge_role"
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
    Name           = "order-charge_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-release_role" {
  name = "order-release_role"
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
    Name           = "order-release_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "lambda_function_order-charge_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-charge-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-charge_st_modlab-b" {
  name        = "lambda_function_order-charge_st_modlab-b"
  description = "Access Policy for order-charge"
  policy      = data.aws_iam_policy_document.lambda_function_order-charge_st_modlab-b_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-charge_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-charge_st_modlab-b.arn
  role       = aws_iam_role.order-charge_role.name
}

data "aws_iam_policy_document" "lambda_function_order-release_st_modlab-b_doc" {
  source_policy_documents = [var.lambda_function_order_release_st_modlab_b_doc_extra_statements_json]
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-release-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-release_st_modlab-b" {
  name        = "lambda_function_order-release_st_modlab-b"
  description = "Access Policy for order-release"
  policy      = data.aws_iam_policy_document.lambda_function_order-release_st_modlab-b_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-release_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-release_st_modlab-b.arn
  role       = aws_iam_role.order-release_role.name
}

output "order_charge_whole" {
  value = aws_lambda_function.order-charge
}

output "order_charge_arn" {
  value = aws_lambda_function.order-charge.arn
}

output "order_release_whole" {
  value = aws_lambda_function.order-release
}

output "order_release_arn" {
  value = aws_lambda_function.order-release.arn
}
