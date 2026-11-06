resource "aws_lambda_function" "agent-lab-chat" {
  function_name                  = "agent-lab-chat"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.agent-lab-chat_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 120
  environment {
    variables = {
      ACCOUNT                                   = "952133486861"
      AWS_BEDROCKAGENTCORE_HARNESS_ARN_0        = "arn:aws:bedrock-agentcore:us-west-2:952133486861:harness/agent_lab_orders-Ul2ksNHdtu"
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_ID_0      = "u0z5jq6ckxrt"
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_VERSION_0 = "DRAFT"
      AWS_LAMBDA_FUNCTION_URL_NAME_0            = "agent-lab-chat-url"
      AWS_XRAY_GROUP_NAME_0                     = "agent-lab-traces"
      NAME                                      = "agent-lab-chat"
      REGION                                    = "us-west-2"
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
    Name           = "agent-lab-chat"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_agent-lab-chat_st_bedrock-agent-lab_attach]
}

resource "aws_lambda_function" "agent-lab-orders-tool" {
  function_name                  = "agent-lab-orders-tool"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.agent-lab-orders-tool_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT                   = "952133486861"
      AWS_DYNAMODB_TABLE_NAME_0 = "agent-lab-orders"
      AWS_XRAY_GROUP_NAME_0     = "agent-lab-traces"
      NAME                      = "agent-lab-orders-tool"
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
  statement_id           = "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat5a8335c8d42053d169ab0b1ad2"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.agent-lab-chat-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat_invoke" {
  function_name            = aws_lambda_function.agent-lab-chat.function_name
  statement_id             = "perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat_invokea4f2aa90bd035a55a36f07b1ee"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.agent-lab-chat-url, aws_lambda_permission.perm_aws_lambda_function_url_agent-lab-chat-url_to_agent-lab-chat]
}
