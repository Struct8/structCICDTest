data "aws_iam_policy_document" "lambda_function_Function1_st_Identity-Policy_doc" {
  statement {
    sid       = "AllowDynamoDBCRUD"
    effect    = "Allow"
    actions   = ["dynamodb:BatchGetItem", "dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.Table1.arn, "${aws_dynamodb_table.Table1.arn}/*"]
  }
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.Queue2.arn]
  }
}

resource "aws_iam_policy" "lambda_function_Function1_st_Identity-Policy" {
  name        = "lambda_function_Function1_st_Identity-Policy"
  description = "Access Policy for Function1"
  policy      = data.aws_iam_policy_document.lambda_function_Function1_st_Identity-Policy_doc.json
}

resource "aws_iam_role" "Function1_role" {
  name = "Function1_role"
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
    Name           = "Function1_role"
    State          = "Identity-Policy"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function1_st_Identity-Policy_attach" {
  policy_arn = aws_iam_policy.lambda_function_Function1_st_Identity-Policy.arn
  role       = aws_iam_role.Function1_role.name
}
