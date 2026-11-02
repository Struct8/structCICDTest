data "aws_iam_policy_document" "lambda_function_api-handler_st_serverless-xray_doc" {
  statement {
    sid       = "ApiHandlerLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.api-handler-logs.arn}:*"]
  }
  statement {
    sid       = "OrdersTableAccess"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.orders-table.arn]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_api-handler_st_serverless-xray" {
  name        = "lambda_function_api-handler_st_serverless-xray"
  description = "Access Policy for api-handler"
  policy      = data.aws_iam_policy_document.lambda_function_api-handler_st_serverless-xray_doc.json
}

data "aws_iam_policy_document" "lambda_function_async-worker_st_serverless-xray_doc" {
  statement {
    sid       = "WorkerLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.async-worker-logs.arn}:*"]
  }
  statement {
    sid       = "WriteOrderResults"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.order-results.arn}/*"]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.order-processing.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_async-worker_st_serverless-xray" {
  name        = "lambda_function_async-worker_st_serverless-xray"
  description = "Access Policy for async-worker"
  policy      = data.aws_iam_policy_document.lambda_function_async-worker_st_serverless-xray_doc.json
}

resource "aws_iam_role" "api-handler_role" {
  name = "api-handler_role"
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
    Name           = "api-handler_role"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "async-worker_role" {
  name = "async-worker_role"
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
    Name           = "async-worker_role"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_api-handler_st_serverless-xray_attach" {
  policy_arn = aws_iam_policy.lambda_function_api-handler_st_serverless-xray.arn
  role       = aws_iam_role.api-handler_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_async-worker_st_serverless-xray_attach" {
  policy_arn = aws_iam_policy.lambda_function_async-worker_st_serverless-xray.arn
  role       = aws_iam_role.async-worker_role.name
}
