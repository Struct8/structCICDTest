data "aws_iam_policy_document" "lambda_function_dlq-lab-consumer_st_dlq-lab_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.dlq-lab-consumer-logs.arn}:*"]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.dlq-lab-orders-queue.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_dlq-lab-consumer_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-consumer_st_dlq-lab"
  description = "Access Policy for dlq-lab-consumer"
  policy      = data.aws_iam_policy_document.lambda_function_dlq-lab-consumer_st_dlq-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.dlq-lab-legacy-notifier-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSQSActions"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq-lab-legacy-dlq.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab"
  description = "Access Policy for dlq-lab-legacy-notifier"
  policy      = data.aws_iam_policy_document.lambda_function_dlq-lab-legacy-notifier_st_dlq-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_dlq-lab-notifier_st_dlq-lab_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.dlq-lab-notifier-logs.arn}:*"]
  }
  statement {
    sid       = "AllowFailureDestination"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.dlq-lab-notifier-failed.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_dlq-lab-notifier_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-notifier_st_dlq-lab"
  description = "Access Policy for dlq-lab-notifier"
  policy      = data.aws_iam_policy_document.lambda_function_dlq-lab-notifier_st_dlq-lab_doc.json
}

data "aws_iam_policy_document" "lambda_function_dlq-lab-producer_st_dlq-lab_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.dlq-lab-producer-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.dlq-lab-orders.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_dlq-lab-producer_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-producer_st_dlq-lab"
  description = "Access Policy for dlq-lab-producer"
  policy      = data.aws_iam_policy_document.lambda_function_dlq-lab-producer_st_dlq-lab_doc.json
}

data "aws_iam_policy_document" "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab_doc" {
  statement {
    sid       = "AllowSchedulerToPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.dlq-lab-orders.arn]
  }
}

resource "aws_iam_policy" "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab" {
  name        = "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab"
  description = "Access Policy for dlq-lab-traffic-ok"
  policy      = data.aws_iam_policy_document.scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab_doc.json
}

resource "aws_iam_role" "dlq-lab-consumer_role" {
  name                  = "dlq-lab-consumer_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-consumer_role"
    State          = "dlq-lab-fix"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "dlq-lab-legacy-notifier_role" {
  name                  = "dlq-lab-legacy-notifier_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-legacy-notifier_role"
    State          = "dlq-lab-fix"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "dlq-lab-notifier_role" {
  name                  = "dlq-lab-notifier_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-notifier_role"
    State          = "dlq-lab-fix"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "dlq-lab-producer_role" {
  name                  = "dlq-lab-producer_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-producer_role"
    State          = "dlq-lab-fix"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "dlq-lab-traffic-ok_role" {
  name                  = "dlq-lab-traffic-ok_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"scheduler.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-traffic-ok_role"
    State          = "dlq-lab-fix"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_dlq-lab-consumer_st_dlq-lab_attach_dlq-lab-consumer_role" {
  policy_arn = aws_iam_policy.lambda_function_dlq-lab-consumer_st_dlq-lab.arn
  role       = aws_iam_role.dlq-lab-consumer_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab_attach_dlq-lab-legacy-notifier_role" {
  policy_arn = aws_iam_policy.lambda_function_dlq-lab-legacy-notifier_st_dlq-lab.arn
  role       = aws_iam_role.dlq-lab-legacy-notifier_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_dlq-lab-notifier_st_dlq-lab_attach_dlq-lab-notifier_role" {
  policy_arn = aws_iam_policy.lambda_function_dlq-lab-notifier_st_dlq-lab.arn
  role       = aws_iam_role.dlq-lab-notifier_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_dlq-lab-producer_st_dlq-lab_attach_dlq-lab-producer_role" {
  policy_arn = aws_iam_policy.lambda_function_dlq-lab-producer_st_dlq-lab.arn
  role       = aws_iam_role.dlq-lab-producer_role.name
}

resource "aws_iam_role_policy_attachment" "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab_attach_dlq-lab-traffic-ok_role" {
  policy_arn = aws_iam_policy.scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab.arn
  role       = aws_iam_role.dlq-lab-traffic-ok_role.name
}
