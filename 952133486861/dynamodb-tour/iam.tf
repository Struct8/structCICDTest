data "aws_iam_policy_document" "lambda_function_StreamConsumer_st_dynamodb-tour_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.StreamConsumer.arn}:*"]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["dynamodb:DescribeStream", "dynamodb:GetRecords", "dynamodb:GetShardIterator"]
    resources = [aws_dynamodb_table.Ledger.stream_arn]
  }
}

resource "aws_iam_policy" "lambda_function_StreamConsumer_st_dynamodb-tour" {
  name        = "lambda_function_StreamConsumer_st_dynamodb-tour"
  description = "Access Policy for StreamConsumer"
  policy      = data.aws_iam_policy_document.lambda_function_StreamConsumer_st_dynamodb-tour_doc.json
}

resource "aws_iam_role" "StreamConsumer_role" {
  name                  = "StreamConsumer_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "StreamConsumer_role"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_StreamConsumer_st_dynamodb-tour_attach" {
  policy_arn = aws_iam_policy.lambda_function_StreamConsumer_st_dynamodb-tour.arn
  role       = aws_iam_role.StreamConsumer_role.name
}
