data "aws_iam_policy_document" "lambda_function_Function3_st_Mix-Inline-and-Identity-Policy_doc" {
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.Queue4.arn]
  }
}

resource "aws_iam_policy" "lambda_function_Function3_st_Mix-Inline-and-Identity-Policy" {
  name        = "lambda_function_Function3_st_Mix-Inline-and-Identity-Policy"
  description = "Access Policy for Function3"
  policy      = data.aws_iam_policy_document.lambda_function_Function3_st_Mix-Inline-and-Identity-Policy_doc.json
}

resource "aws_iam_role" "Function3_role" {
  name = "Function3_role"
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
  inline_policy {
    name = "lambda_function_Function3_st_Mix-Inline-and-Identity-Policy"
    policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.Table3.arn}",
        "${aws_dynamodb_table.Table3.arn}/*"
      ],
      "Sid": "AllowDynamoDBCRUD"
    }
  ]
})
  }
  tags = {
    Name           = "Function3_role"
    State          = "Mix-Inline-and-Identity-Policy"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_Function3_st_Mix-Inline-and-Identity-Policy_attach" {
  policy_arn = aws_iam_policy.lambda_function_Function3_st_Mix-Inline-and-Identity-Policy.arn
  role       = aws_iam_role.Function3_role.name
}
