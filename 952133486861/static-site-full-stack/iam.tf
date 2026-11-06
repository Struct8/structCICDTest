data "aws_iam_policy_document" "lambda_function_presign-url-generator_st_static-site-full-stack_doc" {
  statement {
    sid       = "PresignedObjectAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.site-uploads.arn}/*"]
  }
}

resource "aws_iam_policy" "lambda_function_presign-url-generator_st_static-site-full-stack" {
  name        = "lambda_function_presign-url-generator_st_static-site-full-stack"
  description = "Access Policy for presign-url-generator"
  policy      = data.aws_iam_policy_document.lambda_function_presign-url-generator_st_static-site-full-stack_doc.json
}

resource "aws_iam_role" "presign-url-generator_role" {
  name = "presign-url-generator_role"
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
    Name           = "presign-url-generator_role"
    State          = "static-site-full-stack"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_presign-url-generator_st_static-site-full-stack_attach" {
  policy_arn = aws_iam_policy.lambda_function_presign-url-generator_st_static-site-full-stack.arn
  role       = aws_iam_role.presign-url-generator_role.name
}
