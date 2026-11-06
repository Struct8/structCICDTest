resource "aws_iam_role" "Function2_role" {
  name                  = "Function2_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  inline_policy {
    name = "lambda_function_Function2_st_Inline-Policy"
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
        "${aws_dynamodb_table.Table2.arn}",
        "${aws_dynamodb_table.Table2.arn}/*"
      ],
      "Sid": "AllowDynamoDBCRUD"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.Queue3.arn}"
      ],
      "Sid": "AllowSQSActions"
    }
  ]
})
  }
  tags = {
    Name           = "Function2_role"
    State          = "Inline-Policy"
    Struct8Creator = "rmay struct"
  }
}
