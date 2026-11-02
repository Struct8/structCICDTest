resource "aws_iam_policy" "lambda_function_api-handler_st_serverless-xray" {
  name        = "lambda_function_api-handler_st_serverless-xray"
  description = "Access Policy for api-handler"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.api-handler-logs.arn}:*"
      ],
      "Sid": "ApiHandlerLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.orders-table.arn}"
      ],
      "Sid": "OrdersTableAccess"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "${aws_sns_topic.order-events.arn}"
      ],
      "Sid": "AllowSNSPublish"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowSendTracesToXRay"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_async-worker_st_serverless-xray" {
  name        = "lambda_function_async-worker_st_serverless-xray"
  description = "Access Policy for async-worker"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.async-worker-logs.arn}:*"
      ],
      "Sid": "WorkerLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.order-results.arn}/*"
      ],
      "Sid": "WriteOrderResults"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.order-processing.arn}"
      ],
      "Sid": "AllowEventSourceRead"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowSendTracesToXRay"
    }
  ]
})
}

resource "aws_iam_role" "api-handler_role" {
  name                  = "api-handler_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
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
  name                  = "async-worker_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "async-worker_role"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_api-handler_st_serverless-xray_attach_api-handler_role" {
  policy_arn = aws_iam_policy.lambda_function_api-handler_st_serverless-xray.arn
  role       = aws_iam_role.api-handler_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_async-worker_st_serverless-xray_attach_async-worker_role" {
  policy_arn = aws_iam_policy.lambda_function_async-worker_st_serverless-xray.arn
  role       = aws_iam_role.async-worker_role.name
}
