data "aws_iam_policy_document" "lambda_function_worker_st_lambda-showcase_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.worker-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts.arn]
  }
}

resource "aws_iam_policy" "lambda_function_worker_st_lambda-showcase" {
  name        = "lambda_function_worker_st_lambda-showcase"
  description = "Access Policy for worker"
  policy      = data.aws_iam_policy_document.lambda_function_worker_st_lambda-showcase_doc.json
}

resource "aws_iam_role" "worker_role" {
  name                  = "worker_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "worker_role"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_worker_st_lambda-showcase_attach" {
  policy_arn = aws_iam_policy.lambda_function_worker_st_lambda-showcase.arn
  role       = aws_iam_role.worker_role.name
}
