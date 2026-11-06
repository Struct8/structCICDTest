data "aws_iam_policy_document" "lambda_function_fanout-consumer-a_st_eventbridge-tour_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.logs-fanout-consumer-a.arn}:*"]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.fanout-queue.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_fanout-consumer-a_st_eventbridge-tour" {
  name        = "lambda_function_fanout-consumer-a_st_eventbridge-tour"
  description = "Access Policy for fanout-consumer-a"
  policy      = data.aws_iam_policy_document.lambda_function_fanout-consumer-a_st_eventbridge-tour_doc.json
}

data "aws_iam_policy_document" "lambda_function_fanout-consumer-b_st_eventbridge-tour_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.logs-fanout-consumer-b.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_fanout-consumer-b_st_eventbridge-tour" {
  name        = "lambda_function_fanout-consumer-b_st_eventbridge-tour"
  description = "Access Policy for fanout-consumer-b"
  policy      = data.aws_iam_policy_document.lambda_function_fanout-consumer-b_st_eventbridge-tour_doc.json
}

data "aws_iam_policy_document" "lambda_function_schedule-target-fn_st_eventbridge-tour_doc" {
  statement {
    sid       = "AllowPutEvents"
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.tour-bus.arn]
  }
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.logs-schedule-target-fn.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_schedule-target-fn_st_eventbridge-tour" {
  name        = "lambda_function_schedule-target-fn_st_eventbridge-tour"
  description = "Access Policy for schedule-target-fn"
  policy      = data.aws_iam_policy_document.lambda_function_schedule-target-fn_st_eventbridge-tour_doc.json
}

data "aws_iam_policy_document" "scheduler_schedule_sched-flexible_st_eventbridge-tour_doc" {
  statement {
    sid       = "AllowSchedulerToSendMessage"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.fanout-queue.arn]
  }
}

resource "aws_iam_policy" "scheduler_schedule_sched-flexible_st_eventbridge-tour" {
  name        = "scheduler_schedule_sched-flexible_st_eventbridge-tour"
  description = "Access Policy for sched-flexible"
  policy      = data.aws_iam_policy_document.scheduler_schedule_sched-flexible_st_eventbridge-tour_doc.json
}

resource "aws_iam_role" "fanout-consumer-a_role" {
  name                  = "fanout-consumer-a_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "fanout-consumer-a_role"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "fanout-consumer-b_role" {
  name                  = "fanout-consumer-b_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "fanout-consumer-b_role"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "sched-flexible_role" {
  name                  = "sched-flexible_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"scheduler.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "sched-flexible_role"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "schedule-target-fn_role" {
  name                  = "schedule-target-fn_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "schedule-target-fn_role"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_fanout-consumer-a_st_eventbridge-tour_attach" {
  policy_arn = aws_iam_policy.lambda_function_fanout-consumer-a_st_eventbridge-tour.arn
  role       = aws_iam_role.fanout-consumer-a_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_fanout-consumer-b_st_eventbridge-tour_attach" {
  policy_arn = aws_iam_policy.lambda_function_fanout-consumer-b_st_eventbridge-tour.arn
  role       = aws_iam_role.fanout-consumer-b_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_schedule-target-fn_st_eventbridge-tour_attach" {
  policy_arn = aws_iam_policy.lambda_function_schedule-target-fn_st_eventbridge-tour.arn
  role       = aws_iam_role.schedule-target-fn_role.name
}

resource "aws_iam_role_policy_attachment" "scheduler_schedule_sched-flexible_st_eventbridge-tour_attach" {
  policy_arn = aws_iam_policy.scheduler_schedule_sched-flexible_st_eventbridge-tour.arn
  role       = aws_iam_role.sched-flexible_role.name
}
