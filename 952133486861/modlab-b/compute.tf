resource "aws_lambda_event_source_mapping" "order-approvals-to-inbox" {
  function_name           = aws_lambda_function.order-approval-inbox.arn
  event_source_arn        = aws_sqs_queue.order-approvals.arn
  function_response_types = ["ReportBatchItemFailures"]
  tags = {
    Name           = "order-approvals-to-inbox"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}

data "archive_file" "archive_struct8-templates_order-approval-inbox" {
  output_path = "${path.module}/struct8-templates_order-approval-inbox.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-approval-inbox"
  type        = "zip"
}

resource "aws_lambda_function" "order-approval-inbox" {
  function_name                  = "order-approval-inbox"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-approval-inbox.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-approval-inbox_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-approval-inbox.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                      = "order-approval-inbox"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
      AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-approval-inbox"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-approval-inbox_st_modlab-b_attach]
}

data "archive_file" "archive_struct8-templates_order-console" {
  output_path = "${path.module}/struct8-templates_order-console.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-console"
  type        = "zip"
}

resource "aws_lambda_function" "order-console" {
  function_name                  = "order-console"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-console.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-console_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-console.output_base64sha256
  timeout                        = 15
  environment {
    variables = {
      NAME                           = "order-console"
      REGION                         = data.aws_region.current.region
      ACCOUNT                        = data.aws_caller_identity.current.account_id
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "order-console-url"
      AWS_DYNAMODB_TABLE_NAME_0      = "order-lab-data"
      AWS_SFN_STATE_MACHINE_ARN_0    = aws_sfn_state_machine.order-workflow.arn
      AWS_SQS_QUEUE_NAME_0           = "order-notifications"
      AWS_XRAY_GROUP_NAME_0          = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-console"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-console_st_modlab-b_attach]
}

data "archive_file" "archive_struct8-templates_order-pack-item" {
  output_path = "${path.module}/struct8-templates_order-pack-item.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-pack-item"
  type        = "zip"
}

resource "aws_lambda_function" "order-pack-item" {
  function_name                  = "order-pack-item"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-pack-item.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-pack-item_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-pack-item.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                  = "order-pack-item"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-pack-item"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-pack-item_st_modlab-b_attach]
}

data "archive_file" "archive_struct8-templates_order-reserve" {
  output_path = "${path.module}/struct8-templates_order-reserve.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-reserve"
  type        = "zip"
}

resource "aws_lambda_function" "order-reserve" {
  function_name                  = "order-reserve"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-reserve.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-reserve_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-reserve.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                      = "order-reserve"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "order-lab-data"
      AWS_XRAY_GROUP_NAME_0     = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-reserve"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-reserve_st_modlab-b_attach]
}

data "archive_file" "archive_struct8-templates_order-validate" {
  output_path = "${path.module}/struct8-templates_order-validate.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/stepfunctions-order-lab/v1/lambda/order-validate"
  type        = "zip"
}

resource "aws_lambda_function" "order-validate" {
  function_name                  = "order-validate"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_order-validate.output_path
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.order-validate_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_order-validate.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                  = "order-validate"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_XRAY_GROUP_NAME_0 = "order-lab-traces"
    }
  }
  tags = {
    Name           = "order-validate"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_order-validate_st_modlab-b_attach]
}

resource "aws_lambda_function_url" "order-console-url" {
  function_name      = aws_lambda_function.order-console.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console-url_to_order-console" {
  function_name          = aws_lambda_function.order-console.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_order-console-url_to_order-console"
  depends_on             = [aws_lambda_function_url.order-console-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console-url_to_order-console_invoke" {
  function_name            = aws_lambda_function.order-console.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_order-console-url_to_order-console_invoke"
  depends_on               = [aws_lambda_function_url.order-console-url, aws_lambda_permission.perm_aws_lambda_function_url_order-console-url_to_order-console]
}
