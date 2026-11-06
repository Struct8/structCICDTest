resource "aws_lambda_function" "bedrock-rag-handler" {
  function_name                  = "bedrock-rag-handler"
  architectures                  = ["arm64"]
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.bedrock-rag-handler_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 60
  environment {
    variables = {
      ACCOUNT                                          = data.aws_caller_identity.current.account_id
      AWS_BEDROCKAGENT_DATA_SOURCE_ID_0                = "DJT0B6TZQ3"
      AWS_BEDROCKAGENT_DATA_SOURCE_KNOWLEDGE_BASE_ID_0 = "AGNZ18BSXH"
      AWS_BEDROCKAGENT_KNOWLEDGE_BASE_ID_0             = aws_bedrockagent_knowledge_base.bedrock-kb-lab.id
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_ID_0             = aws_bedrock_guardrail.lab-guardrail.guardrail_id
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_VERSION_0        = aws_bedrock_guardrail.lab-guardrail.version
      AWS_BEDROCK_INFERENCE_PROFILE_ARN_0              = aws_bedrock_inference_profile.bedrock-rag-answer-model.arn
      AWS_LAMBDA_FUNCTION_URL_NAME_0                   = "bedrock-rag-url"
      NAME                                             = "bedrock-rag-handler"
      REGION                                           = data.aws_region.current.region
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
    Name           = "bedrock-rag-handler"
    State          = "bedrock-rag-guardrail-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_bedrock-rag-handler_st_bedrock-rag-guardrail-lab_attach]
}

resource "aws_lambda_function_url" "bedrock-rag-url" {
  function_name      = aws_lambda_function.bedrock-rag-handler.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler" {
  function_name          = aws_lambda_function.bedrock-rag-handler.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler"
  depends_on             = [aws_lambda_function_url.bedrock-rag-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler_invoke" {
  function_name            = aws_lambda_function.bedrock-rag-handler.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler_invoke"
  depends_on               = [aws_lambda_function_url.bedrock-rag-url, aws_lambda_permission.perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler]
}
