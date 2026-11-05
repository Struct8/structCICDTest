resource "aws_iam_policy" "lambda_function_dlq-lab-consumer_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-consumer_st_dlq-lab"
  description = "Access Policy for dlq-lab-consumer"
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
        "${aws_cloudwatch_log_group.dlq-lab-consumer-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.dlq-lab-orders-queue.arn}"
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

resource "aws_iam_policy" "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-legacy-notifier_st_dlq-lab"
  description = "Access Policy for dlq-lab-legacy-notifier"
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
        "${aws_cloudwatch_log_group.dlq-lab-legacy-notifier-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
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
        "${aws_sqs_queue.dlq-lab-legacy-dlq.arn}"
      ],
      "Sid": "AllowSQSActions"
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

resource "aws_iam_policy" "lambda_function_dlq-lab-notifier_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-notifier_st_dlq-lab"
  description = "Access Policy for dlq-lab-notifier"
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
        "${aws_cloudwatch_log_group.dlq-lab-notifier-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.dlq-lab-notifier-failed.arn}"
      ],
      "Sid": "AllowFailureDestination"
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

resource "aws_iam_policy" "lambda_function_dlq-lab-producer_st_dlq-lab" {
  name        = "lambda_function_dlq-lab-producer_st_dlq-lab"
  description = "Access Policy for dlq-lab-producer"
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
        "${aws_cloudwatch_log_group.dlq-lab-producer-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "${aws_sns_topic.dlq-lab-orders.arn}"
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

resource "aws_iam_policy" "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab" {
  name        = "scheduler_schedule_dlq-lab-traffic-ok_st_dlq-lab"
  description = "Access Policy for dlq-lab-traffic-ok"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "${aws_sns_topic.dlq-lab-orders.arn}"
      ],
      "Sid": "AllowSchedulerToPublish"
    }
  ]
})
}

resource "aws_iam_role" "dlq-lab-consumer_role" {
  name                  = "dlq-lab-consumer_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "dlq-lab-consumer_role"
    State          = "dlq-lab"
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
    State          = "dlq-lab"
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
    State          = "dlq-lab"
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
    State          = "dlq-lab"
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
    State          = "dlq-lab"
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
