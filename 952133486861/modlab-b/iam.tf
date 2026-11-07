data "aws_iam_policy_document" "lambda_function_order-approval-inbox_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-approval-inbox-logs.arn}:*"]
  }
  statement {
    sid       = "AllowDynamoDBUpdate"
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.order-lab-data.arn]
  }
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.order-approvals.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-approval-inbox_st_modlab-b" {
  name        = "lambda_function_order-approval-inbox_st_modlab-b"
  description = "Access Policy for order-approval-inbox"
  policy      = data.aws_iam_policy_document.lambda_function_order-approval-inbox_st_modlab-b_doc.json
}

data "aws_iam_policy_document" "lambda_function_order-console_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-console-logs.arn}:*"]
  }
  statement {
    sid       = "AllowDynamoDBReadWrite"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.order-lab-data.arn]
  }
  statement {
    sid       = "AllowStartExecution"
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.order-workflow.arn]
  }
  statement {
    sid       = "AllowReadAndDeleteNotifications"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.order-notifications.arn]
  }
  statement {
    sid       = "AllowCompleteCallbackTasks"
    effect    = "Allow"
    actions   = ["states:SendTaskFailure", "states:SendTaskSuccess", "xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
  statement {
    sid       = "AllowFollowExecutions"
    effect    = "Allow"
    actions   = ["states:DescribeExecution", "states:GetExecutionHistory"]
    resources = ["arn:aws:states:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:execution:${aws_sfn_state_machine.order-workflow.name}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-console_st_modlab-b" {
  name        = "lambda_function_order-console_st_modlab-b"
  description = "Access Policy for order-console"
  policy      = data.aws_iam_policy_document.lambda_function_order-console_st_modlab-b_doc.json
}

data "aws_iam_policy_document" "lambda_function_order-pack-item_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-pack-item-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-pack-item_st_modlab-b" {
  name        = "lambda_function_order-pack-item_st_modlab-b"
  description = "Access Policy for order-pack-item"
  policy      = data.aws_iam_policy_document.lambda_function_order-pack-item_st_modlab-b_doc.json
}

data "aws_iam_policy_document" "lambda_function_order-release_st_modlab-b_doc_extra_statements" {
  statement {
    sid       = "AllowDynamoDBUpdate"
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.order-lab-data.arn]
  }
}

data "aws_iam_policy_document" "lambda_function_order-reserve_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-reserve-logs.arn}:*"]
  }
  statement {
    sid       = "AllowDynamoDBUpdate"
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.order-lab-data.arn]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-reserve_st_modlab-b" {
  name        = "lambda_function_order-reserve_st_modlab-b"
  description = "Access Policy for order-reserve"
  policy      = data.aws_iam_policy_document.lambda_function_order-reserve_st_modlab-b_doc.json
}

data "aws_iam_policy_document" "lambda_function_order-validate_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-validate-logs.arn}:*"]
  }
  statement {
    sid       = "AllowSendTracesToXRay"
    effect    = "Allow"
    actions   = ["xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_order-validate_st_modlab-b" {
  name        = "lambda_function_order-validate_st_modlab-b"
  description = "Access Policy for order-validate"
  policy      = data.aws_iam_policy_document.lambda_function_order-validate_st_modlab-b_doc.json
}

data "aws_iam_policy_document" "sfn_state_machine_order-workflow_st_modlab-b_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.order-workflow-logs.arn}:*"]
  }
  statement {
    sid       = "AllowDynamoDBWrite"
    effect    = "Allow"
    actions   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.order-lab-data.arn]
  }
  statement {
    sid       = "AllowLambdaInvoke"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.pagamento.order_charge_arn]
  }
  statement {
    sid       = "AllowLambdaInvoke1"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.order-pack-item.arn]
  }
  statement {
    sid       = "AllowLambdaInvoke2"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.pagamento.order_release_arn]
  }
  statement {
    sid       = "AllowLambdaInvoke3"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.order-reserve.arn]
  }
  statement {
    sid       = "AllowLambdaInvoke4"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.order-validate.arn]
  }
  statement {
    sid       = "AllowSNSPublish"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
  }
  statement {
    sid       = "AllowSendApprovalRequest"
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.order-approvals.arn]
  }
  statement {
    sid       = "DeliverExecutionLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogDelivery", "logs:CreateLogStream", "logs:DeleteLogDelivery", "logs:DescribeLogGroups", "logs:DescribeResourcePolicies", "logs:GetLogDelivery", "logs:ListLogDeliveries", "logs:PutLogEvents", "logs:PutResourcePolicy", "logs:UpdateLogDelivery", "xray:GetSamplingRules", "xray:GetSamplingTargets", "xray:PutTelemetryRecords", "xray:PutTraceSegments"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sfn_state_machine_order-workflow_st_modlab-b" {
  name        = "sfn_state_machine_order-workflow_st_modlab-b"
  description = "Access Policy for order-workflow"
  policy      = data.aws_iam_policy_document.sfn_state_machine_order-workflow_st_modlab-b_doc.json
}

resource "aws_iam_role" "order-approval-inbox_role" {
  name = "order-approval-inbox_role"
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
    Name           = "order-approval-inbox_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-console_role" {
  name = "order-console_role"
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
    Name           = "order-console_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-pack-item_role" {
  name = "order-pack-item_role"
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
    Name           = "order-pack-item_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-reserve_role" {
  name = "order-reserve_role"
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
    Name           = "order-reserve_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-validate_role" {
  name = "order-validate_role"
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
    Name           = "order-validate_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-workflow_role" {
  name = "order-workflow_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-workflow_role"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-approval-inbox_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-approval-inbox_st_modlab-b.arn
  role       = aws_iam_role.order-approval-inbox_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-console_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-console_st_modlab-b.arn
  role       = aws_iam_role.order-console_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-pack-item_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-pack-item_st_modlab-b.arn
  role       = aws_iam_role.order-pack-item_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-reserve_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-reserve_st_modlab-b.arn
  role       = aws_iam_role.order-reserve_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-validate_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.lambda_function_order-validate_st_modlab-b.arn
  role       = aws_iam_role.order-validate_role.name
}

resource "aws_iam_role_policy_attachment" "sfn_state_machine_order-workflow_st_modlab-b_attach" {
  policy_arn = aws_iam_policy.sfn_state_machine_order-workflow_st_modlab-b.arn
  role       = aws_iam_role.order-workflow_role.name
}
