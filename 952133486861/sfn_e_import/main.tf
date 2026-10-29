terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/sfn_e_import/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_policy" "lambda_function_order-approval-inbox_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-approval-inbox_st_stepfunctions-order-lab"
  description = "Access Policy for order-approval-inbox"
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
        "${aws_cloudwatch_log_group.order-approval-inbox-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.order-lab-data.arn}"
      ],
      "Sid": "AllowDynamoDBUpdate"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.order-approvals.arn}"
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

resource "aws_iam_policy" "lambda_function_order-charge_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-charge_st_stepfunctions-order-lab"
  description = "Access Policy for order-charge"
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
        "${aws_cloudwatch_log_group.order-charge-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
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

resource "aws_iam_policy" "lambda_function_order-console_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-console_st_stepfunctions-order-lab"
  description = "Access Policy for order-console"
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
        "${aws_cloudwatch_log_group.order-console-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.order-lab-data.arn}"
      ],
      "Sid": "AllowDynamoDBReadWrite"
    },
    {
      "Effect": "Allow",
      "Action": [
        "states:StartExecution"
      ],
      "Resource": [
        "${aws_sfn_state_machine.order-workflow.arn}"
      ],
      "Sid": "AllowStartExecution"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.order-notifications.arn}"
      ],
      "Sid": "AllowReadAndDeleteNotifications"
    },
    {
      "Effect": "Allow",
      "Action": [
        "states:SendTaskFailure",
        "states:SendTaskSuccess",
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "AllowCompleteCallbackTasks"
    },
    {
      "Effect": "Allow",
      "Action": [
        "states:DescribeExecution",
        "states:GetExecutionHistory"
      ],
      "Resource": [
        "arn:aws:states:us-west-2:952133486861:execution:order-workflow:*"
      ],
      "Sid": "AllowFollowExecutions"
    }
  ]
})
}

resource "aws_iam_policy" "lambda_function_order-pack-item_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-pack-item_st_stepfunctions-order-lab"
  description = "Access Policy for order-pack-item"
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
        "${aws_cloudwatch_log_group.order-pack-item-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
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

resource "aws_iam_policy" "lambda_function_order-release_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-release_st_stepfunctions-order-lab"
  description = "Access Policy for order-release"
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
        "${aws_cloudwatch_log_group.order-release-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.order-lab-data.arn}"
      ],
      "Sid": "AllowDynamoDBUpdate"
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

resource "aws_iam_policy" "lambda_function_order-reserve_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-reserve_st_stepfunctions-order-lab"
  description = "Access Policy for order-reserve"
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
        "${aws_cloudwatch_log_group.order-reserve-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.order-lab-data.arn}"
      ],
      "Sid": "AllowDynamoDBUpdate"
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

resource "aws_iam_policy" "lambda_function_order-validate_st_stepfunctions-order-lab" {
  name        = "lambda_function_order-validate_st_stepfunctions-order-lab"
  description = "Access Policy for order-validate"
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
        "${aws_cloudwatch_log_group.order-validate-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
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

resource "aws_iam_policy" "sfn_state_machine_order-workflow_st_stepfunctions-order-lab" {
  name        = "sfn_state_machine_order-workflow_st_stepfunctions-order-lab"
  description = "Access Policy for order-workflow"
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
        "${aws_cloudwatch_log_group.order-workflow-logs.arn}:*"
      ],
      "Sid": "AllowWriteLogs"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": [
        "${aws_dynamodb_table.order-lab-data.arn}"
      ],
      "Sid": "AllowDynamoDBWrite"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.order-charge.arn}"
      ],
      "Sid": "AllowLambdaInvoke"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.order-pack-item.arn}"
      ],
      "Sid": "AllowLambdaInvoke1"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.order-release.arn}"
      ],
      "Sid": "AllowLambdaInvoke2"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.order-reserve.arn}"
      ],
      "Sid": "AllowLambdaInvoke3"
    },
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "${aws_lambda_function.order-validate.arn}"
      ],
      "Sid": "AllowLambdaInvoke4"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": [
        "${aws_sns_topic.order-events.arn}"
      ],
      "Sid": "AllowSNSPublish"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.order-approvals.arn}"
      ],
      "Sid": "AllowSendApprovalRequest"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:CreateLogStream",
        "logs:DeleteLogDelivery",
        "logs:DescribeLogGroups",
        "logs:DescribeResourcePolicies",
        "logs:GetLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutLogEvents",
        "logs:PutResourcePolicy",
        "logs:UpdateLogDelivery",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets",
        "xray:PutTelemetryRecords",
        "xray:PutTraceSegments"
      ],
      "Resource": [
        "*"
      ],
      "Sid": "DeliverExecutionLogs"
    }
  ]
})
}

resource "aws_iam_role" "order-approval-inbox_role" {
  name                  = "order-approval-inbox_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-approval-inbox_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-charge_role" {
  name                  = "order-charge_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-charge_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-console_role" {
  name                  = "order-console_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-console_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-pack-item_role" {
  name                  = "order-pack-item_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-pack-item_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-release_role" {
  name                  = "order-release_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-release_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-reserve_role" {
  name                  = "order-reserve_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-reserve_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-validate_role" {
  name                  = "order-validate_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-validate_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "order-workflow_role" {
  name                  = "order-workflow_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"states.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "order-workflow_role"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-approval-inbox_st_stepfunctions-order-lab_attach_order-approval-inbox_role" {
  policy_arn = aws_iam_policy.lambda_function_order-approval-inbox_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-approval-inbox_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-charge_st_stepfunctions-order-lab_attach_order-charge_role" {
  policy_arn = aws_iam_policy.lambda_function_order-charge_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-charge_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-console_st_stepfunctions-order-lab_attach_order-console_role" {
  policy_arn = aws_iam_policy.lambda_function_order-console_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-console_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-pack-item_st_stepfunctions-order-lab_attach_order-pack-item_role" {
  policy_arn = aws_iam_policy.lambda_function_order-pack-item_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-pack-item_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-release_st_stepfunctions-order-lab_attach_order-release_role" {
  policy_arn = aws_iam_policy.lambda_function_order-release_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-release_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-reserve_st_stepfunctions-order-lab_attach_order-reserve_role" {
  policy_arn = aws_iam_policy.lambda_function_order-reserve_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-reserve_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_order-validate_st_stepfunctions-order-lab_attach_order-validate_role" {
  policy_arn = aws_iam_policy.lambda_function_order-validate_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-validate_role.name
}

resource "aws_iam_role_policy_attachment" "sfn_state_machine_order-workflow_st_stepfunctions-order-lab_attach_order-workflow_role" {
  policy_arn = aws_iam_policy.sfn_state_machine_order-workflow_st_stepfunctions-order-lab.arn
  role       = aws_iam_role.order-workflow_role.name
}




### CATEGORY: DATABASE ###

resource "aws_dynamodb_table" "order-lab-data" {
  name                        = "order-lab-data"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "pk"
  range_key                   = "sk"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  point_in_time_recovery {
    enabled = false
  }
  tags = {
    Name           = "order-lab-data"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  ttl {
    enabled = false
  }
}




### CATEGORY: COMPUTE ###

resource "aws_lambda_event_source_mapping" "order-approvals-to-inbox" {
  function_name           = aws_lambda_function.order-approval-inbox.arn
  batch_size              = 10
  event_source_arn        = aws_sqs_queue.order-approvals.arn
  function_response_types = ["ReportBatchItemFailures"]
  tags = {
    Name           = "order-approvals-to-inbox"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lambda_function" "order-approval-inbox" {
  function_name                  = "order-approval-inbox"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-approval-inbox_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT                   = "952133486861"
    AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
    AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    NAME                      = "order-approval-inbox"
    REGION                    = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-approval-inbox"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-approval-inbox_st_stepfunctions-order-lab_attach_order-approval-inbox_role]
}

resource "aws_lambda_function" "order-charge" {
  function_name                  = "order-charge"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-charge_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT               = "952133486861"
    AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    NAME                  = "order-charge"
    REGION                = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-charge"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-charge_st_stepfunctions-order-lab_attach_order-charge_role]
}

resource "aws_lambda_function" "order-console" {
  function_name                  = "order-console"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-console_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 15
  environment {
    variables = {
    ACCOUNT                        = "952133486861"
    AWS_DYNAMODB_TABLE_NAME_0      = "order-lab-data"
    AWS_LAMBDA_FUNCTION_URL_NAME_0 = "order-console-url"
    AWS_SFN_STATE_MACHINE_ARN_0    = "arn:aws:states:us-west-2:952133486861:stateMachine:order-workflow"
    AWS_SQS_QUEUE_NAME_0           = "order-notifications"
    AWS_XRAY_GROUP_NAME_0          = "order-lab-traces"
    NAME                           = "order-console"
    REGION                         = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-console"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-console_st_stepfunctions-order-lab_attach_order-console_role]
}

resource "aws_lambda_function" "order-pack-item" {
  function_name                  = "order-pack-item"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-pack-item_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT               = "952133486861"
    AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    NAME                  = "order-pack-item"
    REGION                = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-pack-item"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-pack-item_st_stepfunctions-order-lab_attach_order-pack-item_role]
}

resource "aws_lambda_function" "order-release" {
  function_name                  = "order-release"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-release_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT                   = "952133486861"
    AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
    AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    NAME                      = "order-release"
    REGION                    = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-release"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-release_st_stepfunctions-order-lab_attach_order-release_role]
}

resource "aws_lambda_function" "order-reserve" {
  function_name                  = "order-reserve"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-reserve_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT                   = "952133486861"
    AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
    AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    NAME                      = "order-reserve"
    REGION                    = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-reserve"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-reserve_st_stepfunctions-order-lab_attach_order-reserve_role]
}

resource "aws_lambda_function" "order-validate" {
  function_name                  = "order-validate"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-validate_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
    ACCOUNT               = "952133486861"
    AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    NAME                  = "order-validate"
    REGION                = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "order-validate"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-validate_st_stepfunctions-order-lab_attach_order-validate_role]
}

resource "aws_lambda_function_url" "order-console" {
  function_name      = aws_lambda_function.order-console.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console_to_order-console" {
  function_name          = aws_lambda_function.order-console.function_name
  statement_id           = "perm_aws_lambda_function_url_order-console-url_to_order-consolead7f6e9527e86115ffb969333e"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.order-console]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console_to_order-console_invoke" {
  function_name            = aws_lambda_function.order-console.function_name
  statement_id             = "perm_aws_lambda_function_url_order-console-url_to_order-console_invokec749ed41c68ba62fcceba166fb"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.order-console, aws_lambda_permission.perm_aws_lambda_function_url_order-console_to_order-console]
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "order-approvals" {
  name                              = "order-approvals"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "order-approvals"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sqs_queue" "order-notifications" {
  name                              = "order-notifications"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 86400
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "order-notifications"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_order-notifications_st_sfn_e_import_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.order-notifications.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_order-notifications_st_sfn_e_import" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_order-notifications_st_sfn_e_import_doc.json
  queue_url = aws_sqs_queue.order-notifications.id
}

resource "aws_sns_topic" "order-events" {
  name           = "order-events"
  tracing_config = "Active"
  tags = {
    Name           = "order-events"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_xray_resource_policy.aws_xray_resource_policy_st_stepfunctions-order-lab_eefa8817da, aws_sqs_queue_policy.aws_sqs_queue_policy_order-notifications_st_sfn_e_import]
}

data "aws_iam_policy_document" "aws_sns_topic_policy_order-events_st_sfn_e_import_doc" {
  statement {
    sid    = "AllowCloudWatchAlarmsToPublish"
    effect = "Allow"
    principals {
      identifiers = ["cloudwatch.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowEventBridgeToPublishToSNS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.order-events.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_order-events_st_sfn_e_import" {
  arn    = aws_sns_topic.order-events.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_order-events_st_sfn_e_import_doc.json
}

resource "aws_sns_topic_subscription" "r_45f149f0-31f4-453f-b131-73e02562dfba" {
  endpoint  = aws_sqs_queue.order-notifications.arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.order-events.arn
}

resource "aws_cloudwatch_event_rule" "order-failure-alerts" {
  name          = "order-failure-alerts"
  description   = "Executions of order-workflow that end FAILED, TIMED_OUT or ABORTED."
  event_pattern = "{\"detail\":{\"stateMachineArn\":[\"arn:aws:states:us-west-2:952133486861:stateMachine:order-workflow\"],\"status\":[\"FAILED\",\"TIMED_OUT\",\"ABORTED\"]},\"detail-type\":[\"Step Functions Execution Status Change\"],\"source\":[\"aws.states\"]}"
  state         = "ENABLED"
  tags = {
    Name           = "order-failure-alerts"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_order-events_st_sfn_e_import]
}

resource "aws_cloudwatch_event_target" "order-failure-alerts_terraform-4qecjpc4NYC9KKgAfw8ugn3TEf" {
  target_id = "terraform-4qecjpc4NYC9KKgAfw8ugn3TEf"
  arn       = aws_sns_topic.order-events.arn
  rule      = aws_cloudwatch_event_rule.order-failure-alerts.name
}

resource "aws_sfn_state_machine" "order-workflow" {
  name = "order-workflow"
  definition = <<EOF
{
  "Comment": "Order workflow of the stepfunctions-order-lab template. The execution name is the order id.",
  "StartAt": "ValidateOrder",
  "States": {
    "ValidateOrder": {
      "Type": "Task",
      "Comment": "Task with Catch: an invalid order goes to MarkRejected.",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-2:952133486861:function:order-validate",
        "Payload": { "order.$": "$", "orderId.$": "$$.Execution.Name" }
      },
      "OutputPath": "$.Payload",
      "Retry": [
        {
          "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"],
          "IntervalSeconds": 1, "MaxAttempts": 3, "BackoffRate": 2
        }
      ],
      "Catch": [{ "ErrorEquals": ["InvalidOrder"], "ResultPath": "$.error", "Next": "MarkRejected" }],
      "Next": "SaveOrder"
    },
    "SaveOrder": {
      "Type": "Task",
      "Comment": "Direct service integration: DynamoDB PutItem, with no Lambda in between.",
      "Resource": "arn:aws:states:::dynamodb:putItem",
      "Parameters": {
        "TableName": "order-lab-data",
        "Item": {
          "pk": { "S": "ORDER" },
          "sk": { "S.$": "$$.Execution.Name" },
          "customer": { "S.$": "$.customer" },
          "scenario": { "S.$": "$.scenario" },
          "items": { "S.$": "States.JsonToString($.items)" },
          "total": { "N.$": "States.Format('{}', $.total)" },
          "status": { "S": "RECEIVED" },
          "createdAt": { "S.$": "$$.Execution.StartTime" },
          "updatedAt": { "S.$": "$$.State.EnteredTime" }
        }
      },
      "ResultPath": null,
      "Next": "NeedsApproval"
    },
    "NeedsApproval": {
      "Type": "Choice",
      "Comment": "Choice: an order above 1000 waits for a person.",
      "Choices": [{ "Variable": "$.total", "NumericGreaterThan": 1000, "Next": "WaitForApproval" }],
      "Default": "ReserveStock"
    },
    "WaitForApproval": {
      "Type": "Task",
      "Comment": "Callback: the task token goes to SQS, and the execution waits for SendTaskSuccess or SendTaskFailure, for 5 minutes at most.",
      "Resource": "arn:aws:states:::sqs:sendMessage.waitForTaskToken",
      "Parameters": {
        "QueueUrl": "https://sqs.us-west-2.amazonaws.com/952133486861/order-approvals",
        "MessageBody": {
          "orderId.$": "$$.Execution.Name",
          "customer.$": "$.customer",
          "total.$": "$.total",
          "taskToken.$": "$$.Task.Token"
        }
      },
      "TimeoutSeconds": 300,
      "ResultPath": "$.approval",
      "Catch": [
        { "ErrorEquals": ["ApprovalRejected"], "ResultPath": "$.error", "Next": "MarkRejected" },
        { "ErrorEquals": ["States.Timeout"], "ResultPath": "$.error", "Next": "MarkApprovalTimedOut" }
      ],
      "Next": "ReserveStock"
    },
    "ReserveStock": {
      "Type": "Task",
      "Comment": "A business error: OutOfStock comes from a conditional write on the stock.",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-2:952133486861:function:order-reserve",
        "Payload.$": "$"
      },
      "ResultSelector": { "items.$": "$.Payload.items" },
      "ResultPath": "$.reservation",
      "Retry": [
        {
          "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"],
          "IntervalSeconds": 1, "MaxAttempts": 3, "BackoffRate": 2
        }
      ],
      "Catch": [{ "ErrorEquals": ["OutOfStock"], "ResultPath": "$.error", "Next": "MarkRejected" }],
      "Next": "ChargePayment"
    },
    "ChargePayment": {
      "Type": "Task",
      "Comment": "Retry with backoff: a gateway that does not answer is tried again after 2 and 4 seconds. A declined card is not retried.",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-2:952133486861:function:order-charge",
        "Payload": { "order.$": "$", "attempt.$": "$$.State.RetryCount" }
      },
      "ResultSelector": {
        "paymentId.$": "$.Payload.paymentId",
        "amount.$": "$.Payload.amount",
        "attempts.$": "$.Payload.attempts"
      },
      "ResultPath": "$.payment",
      "Retry": [
        { "ErrorEquals": ["PaymentGatewayUnavailable"], "IntervalSeconds": 2, "MaxAttempts": 3, "BackoffRate": 2 },
        {
          "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"],
          "IntervalSeconds": 1, "MaxAttempts": 3, "BackoffRate": 2
        }
      ],
      "Catch": [{ "ErrorEquals": ["States.ALL"], "ResultPath": "$.error", "Next": "ReleaseStock" }],
      "Next": "PackItems"
    },
    "ReleaseStock": {
      "Type": "Task",
      "Comment": "Compensation: the stock reserved for this order goes back before the order is marked as failed.",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-2:952133486861:function:order-release",
        "Payload.$": "$"
      },
      "ResultPath": null,
      "Retry": [
        {
          "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"],
          "IntervalSeconds": 1, "MaxAttempts": 3, "BackoffRate": 2
        }
      ],
      "Next": "MarkPaymentFailed"
    },
    "PackItems": {
      "Type": "Map",
      "Comment": "Map: one PackItem per item of the order, at most 3 at the same time.",
      "ItemsPath": "$.items",
      "MaxConcurrency": 3,
      "ItemSelector": { "orderId.$": "$$.Execution.Name", "item.$": "$$.Map.Item.Value" },
      "ItemProcessor": {
        "ProcessorConfig": { "Mode": "INLINE" },
        "StartAt": "PackItem",
        "States": {
          "PackItem": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "Parameters": {
              "FunctionName": "arn:aws:lambda:us-west-2:952133486861:function:order-pack-item",
              "Payload.$": "$"
            },
            "OutputPath": "$.Payload",
            "Retry": [
              {
                "ErrorEquals": ["Lambda.ServiceException", "Lambda.AWSLambdaException", "Lambda.SdkClientException", "Lambda.TooManyRequestsException"],
                "IntervalSeconds": 1, "MaxAttempts": 3, "BackoffRate": 2
              }
            ],
            "End": true
          }
        }
      },
      "ResultPath": "$.packages",
      "Next": "CompleteOrder"
    },
    "CompleteOrder": {
      "Type": "Parallel",
      "Comment": "Parallel: the order is marked as completed and the event is published to SNS at the same time.",
      "Branches": [
        {
          "StartAt": "MarkCompleted",
          "States": {
            "MarkCompleted": {
              "Type": "Task",
              "Resource": "arn:aws:states:::dynamodb:updateItem",
              "Parameters": {
                "TableName": "order-lab-data",
                "Key": { "pk": { "S": "ORDER" }, "sk": { "S.$": "$$.Execution.Name" } },
                "UpdateExpression": "SET #status = :status, #packages = :packages, #paymentId = :paymentId, #updatedAt = :now",
                "ExpressionAttributeNames": {
                  "#status": "status", "#packages": "packages", "#paymentId": "paymentId", "#updatedAt": "updatedAt"
                },
                "ExpressionAttributeValues": {
                  ":status": { "S": "COMPLETED" },
                  ":packages": { "S.$": "States.JsonToString($.packages)" },
                  ":paymentId": { "S.$": "$.payment.paymentId" },
                  ":now": { "S.$": "$$.State.EnteredTime" }
                }
              },
              "End": true
            }
          }
        },
        {
          "StartAt": "PublishCompleted",
          "States": {
            "PublishCompleted": {
              "Type": "Task",
              "Resource": "arn:aws:states:::sns:publish",
              "Parameters": {
                "TopicArn": "arn:aws:sns:us-west-2:952133486861:order-events",
                "Subject": "Order completed",
                "Message.$": "States.Format('Order {} for {} completed. Lines: {}. Total: {}. Payment: {}.', $$.Execution.Name,$.customer, States.ArrayLength($.items), $.total, $.payment.paymentId)"
              },
              "End": true
            }
          }
        }
      ],
      "ResultPath": null,
      "Next": "OrderCompleted"
    },
    "OrderCompleted": { "Type": "Succeed" },
    "MarkRejected": {
      "Type": "Pass",
      "Parameters": { "status": "REJECTED", "error": "OrderRejected", "cause.$": "States.JsonToString($.error)" },
      "ResultPath": "$.outcome",
      "Next": "RecordOutcome"
    },
    "MarkApprovalTimedOut": {
      "Type": "Pass",
      "Parameters": { "status": "APPROVAL_TIMED_OUT", "error": "ApprovalTimedOut", "cause.$": "States.JsonToString($.error)" },
      "ResultPath": "$.outcome",
      "Next": "RecordOutcome"
    },
    "MarkPaymentFailed": {
      "Type": "Pass",
      "Parameters": { "status": "PAYMENT_FAILED", "error": "PaymentFailed", "cause.$": "States.JsonToString($.error)" },
      "ResultPath": "$.outcome",
      "Next": "RecordOutcome"
    },
    "RecordOutcome": {
      "Type": "Task",
      "Comment": "UpdateItem also creates the record, for an order rejected before SaveOrder wrote it.",
      "Resource": "arn:aws:states:::dynamodb:updateItem",
      "Parameters": {
        "TableName": "order-lab-data",
        "Key": { "pk": { "S": "ORDER" }, "sk": { "S.$": "$$.Execution.Name" } },
        "UpdateExpression": "SET #status = :status, #reason = :reason, #updatedAt = :now, #createdAt = if_not_exists(#createdAt, :started), #scenario = if_not_exists(#scenario, :scenario), #customer = if_not_exists(#customer, :customer) REMOVE #taskToken",
        "ExpressionAttributeNames": {
          "#status": "status", "#reason": "reason", "#updatedAt": "updatedAt", "#createdAt": "createdAt",
          "#scenario": "scenario", "#customer": "customer", "#taskToken": "taskToken"
        },
        "ExpressionAttributeValues": {
          ":status": { "S.$": "$.outcome.status" },
          ":reason": { "S.$": "$.outcome.cause" },
          ":now": { "S.$": "$$.State.EnteredTime" },
          ":started": { "S.$": "$$.Execution.StartTime" },
          ":scenario": { "S.$": "States.Format('{}', $.scenario)" },
          ":customer": { "S.$": "States.Format('{}', $.customer)" }
        }
      },
      "ResultPath": null,
      "Next": "OrderFailed"
    },
    "OrderFailed": {
      "Type": "Fail",
      "ErrorPath": "$.outcome.error",
      "CausePath": "$.outcome.cause"
    }
  }
}
  EOF
  role_arn = aws_iam_role.order-workflow_role.arn
  logging_configuration {
    include_execution_data = true
    level                  = "ALL"
    log_destination        = "${aws_cloudwatch_log_group.order-workflow-logs.arn}:*"
  }
  tags = {
    Name           = "order-workflow"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_configuration {
    enabled = true
  }
  depends_on = [aws_iam_role_policy_attachment.sfn_state_machine_order-workflow_st_stepfunctions-order-lab_attach_order-workflow_role]
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "order-approval-inbox-logs" {
  name              = "/aws/lambda/order-approval-inbox"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-approval-inbox-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-charge-logs" {
  name              = "/aws/lambda/order-charge"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-charge-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-console-logs" {
  name              = "/aws/lambda/order-console"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-console-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-pack-item-logs" {
  name              = "/aws/lambda/order-pack-item"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-pack-item-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-release-logs" {
  name              = "/aws/lambda/order-release"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-release-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-reserve-logs" {
  name              = "/aws/lambda/order-reserve"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-reserve-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-validate-logs" {
  name              = "/aws/lambda/order-validate"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-validate-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "order-workflow-logs" {
  name              = "/aws/vendedlogs/states/order-workflow"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "order-workflow-logs"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_metric_alarm" "order-executions-failed" {
  alarm_name          = "order-executions-failed"
  metric_name         = "ExecutionsFailed"
  alarm_actions       = ["arn:aws:sns:us-west-2:952133486861:order-events"]
  alarm_description   = "At least one execution of order-workflow failed in the last minute."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/States"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  dimensions = {
    StateMachineArn = "arn:aws:states:us-west-2:952133486861:stateMachine:order-workflow"
  }
  tags = {
    Name           = "order-executions-failed"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_order-events_st_sfn_e_import]
}

resource "aws_xray_group" "order-lab-traces" {
  group_name        = "order-lab-traces"
  filter_expression = "service(\"order-approval-inbox\") OR service(\"order-charge\") OR service(\"order-console\") OR service(\"order-events\") OR service(\"order-pack-item\") OR service(\"order-release\") OR service(\"order-reserve\") OR service(\"order-validate\") OR service(\"order-workflow\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "order-lab-traces"
    State          = "stepfunctions-order-lab"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_xray_resource_policy_st_stepfunctions-order-lab_eefa8817da_doc" {
  statement {
    sid    = "AllowSNSToSendTracesToXRay"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["xray:GetSamplingRules", "xray:GetSamplingTargets", "xray:PutTraceSegments"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "StringLike"
      values   = ["arn:aws:sns:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_xray_resource_policy" "aws_xray_resource_policy_st_stepfunctions-order-lab_eefa8817da" {
  policy_name     = "aws_xray_resource_policy_st_stepfunctions-order-lab_eefa8817da"
  policy_document = data.aws_iam_policy_document.aws_xray_resource_policy_st_stepfunctions-order-lab_eefa8817da_doc.json
}


