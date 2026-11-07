data "aws_iam_policy_document" "lambda_function_processor_st_modlab-a_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.processor-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_processor_st_modlab-a" {
  name        = "lambda_function_processor_st_modlab-a"
  description = "Access Policy for processor"
  policy      = data.aws_iam_policy_document.lambda_function_processor_st_modlab-a_doc.json
}

resource "aws_iam_role" "processor_role" {
  name = "processor_role"
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
    Name           = "processor_role"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_processor_st_modlab-a_attach" {
  policy_arn = aws_iam_policy.lambda_function_processor_st_modlab-a.arn
  role       = aws_iam_role.processor_role.name
}
