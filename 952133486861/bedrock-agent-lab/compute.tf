data "archive_file" "archive_struct8-templates_agent-lab-chat" {
  output_path = "${path.module}/struct8-templates_agent-lab-chat.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/bedrock-agent-lab/v1/lambda/chat"
  type        = "zip"
}

resource "aws_lambda_function" "agent-lab-chat" {
  function_name                  = "agent-lab-chat"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_agent-lab-chat.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.agent-lab-chat_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_agent-lab-chat.output_base64sha256
  timeout                        = 120
  environment {
    variables = {
      NAME                                      = "agent-lab-chat"
      REGION                                    = data.aws_region.current.region
      ACCOUNT                                   = data.aws_caller_identity.current.account_id
      AWS_LAMBDA_FUNCTION_URL_NAME_0            = "agent-lab-chat-url"
      AWS_BEDROCKAGENTCORE_HARNESS_ARN_0        = aws_bedrockagentcore_harness.agent_lab_orders.arn
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_ID_0      = aws_bedrock_guardrail.agent-lab-guardrail.guardrail_id
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_VERSION_0 = aws_bedrock_guardrail.agent-lab-guardrail.version
      AWS_XRAY_GROUP_NAME_0                     = "agent-lab-traces"
    }
  }
  tags = {
    Name           = "agent-lab-chat"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_agent-lab-chat_st_bedrock-agent-lab_attach]
}

data "archive_file" "archive_struct8-templates_agent-lab-orders-tool" {
  output_path = "${path.module}/struct8-templates_agent-lab-orders-tool.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/bedrock-agent-lab/v1/lambda/orders-tool"
  type        = "zip"
}

resource "aws_lambda_function" "agent-lab-orders-tool" {
  function_name                  = "agent-lab-orders-tool"
  architectures                  = ["arm64"]
  filename                       = data.archive_file.archive_struct8-templates_agent-lab-orders-tool.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.agent-lab-orders-tool_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-templates_agent-lab-orders-tool.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                      = "agent-lab-orders-tool"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "agent-lab-orders"
      AWS_XRAY_GROUP_NAME_0     = "agent-lab-traces"
    }
  }
  tags = {
    Name           = "agent-lab-orders-tool"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_agent-lab-orders-tool_st_bedrock-agent-lab_attach]
}

resource "aws_lambda_function_url" "agent-lab-chat-url" {
  function_name      = aws_lambda_function.agent-lab-chat.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat" {
  function_name          = aws_lambda_function.agent-lab-chat.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat"
  depends_on             = [aws_lambda_function_url.agent-lab-chat-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat_invoke" {
  function_name            = aws_lambda_function.agent-lab-chat.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat_invoke"
  depends_on               = [aws_lambda_function_url.agent-lab-chat-url, aws_lambda_permission.perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat]
}
