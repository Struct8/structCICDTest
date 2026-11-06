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
      ACCOUNT                                          = "952133486861"
      AWS_BEDROCKAGENT_DATA_SOURCE_ID_0                = "DJT0B6TZQ3"
      AWS_BEDROCKAGENT_DATA_SOURCE_KNOWLEDGE_BASE_ID_0 = "AGNZ18BSXH"
      AWS_BEDROCKAGENT_KNOWLEDGE_BASE_ID_0             = "AGNZ18BSXH"
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_ID_0             = "b6mvskbqxnne"
      AWS_BEDROCK_GUARDRAIL_GUARDRAIL_VERSION_0        = "DRAFT"
      AWS_BEDROCK_INFERENCE_PROFILE_ARN_0              = "arn:aws:bedrock:us-west-2:952133486861:application-inference-profile/71rt9ymm0fli"
      AWS_LAMBDA_FUNCTION_URL_NAME_0                   = "bedrock-rag-url"
      NAME                                             = "bedrock-rag-handler"
      REGION                                           = "us-west-2"
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
  statement_id           = "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handlera3bcd411d4503709c5c435c595"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.bedrock-rag-url]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler_invoke" {
  function_name            = aws_lambda_function.bedrock-rag-handler.function_name
  statement_id             = "perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler_invoke9afd67d2efa15922862ed70702"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.bedrock-rag-url, aws_lambda_permission.perm_aws_lambda_function_url_bedrock-rag-url_to_bedrock-rag-handler]
}
