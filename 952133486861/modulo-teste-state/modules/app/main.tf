variable "arquivos_bucket" {
  type = any
}

variable "lambda_function_processador_st_modulo_teste_state_doc_extra_statements_json" {
  type = any
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_lambda_function" "processador" {
  function_name                  = "processador"
  architectures                  = ["arm64"]
  filename                       = "lambda.zip"
  handler                        = "index.lambda_handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.processador_role.arn
  runtime                        = "python3.13"
  timeout                        = 30
  environment {
    variables = {
      NAME                 = "processador"
      REGION               = data.aws_region.current.region
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0 = var.arquivos_bucket
    }
  }
  tags = {
    Name           = "processador"
    State          = "modulo-teste-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_processador_st_modulo-teste-state_attach]
}

resource "aws_sqs_queue" "pedidos" {
  name                              = "pedidos"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "pedidos"
    State          = "modulo-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lambda_event_source_mapping" "pedidos-gatilho" {
  function_name           = aws_lambda_function.processador.arn
  event_source_arn        = aws_sqs_queue.pedidos.arn
  function_response_types = ["ReportBatchItemFailures"]
  tags = {
    Name           = "pedidos-gatilho"
    State          = "modulo-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "processador_role" {
  name = "processador_role"
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
    Name           = "processador_role"
    State          = "modulo-teste-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "lambda_function_processador_st_modulo-teste-state_doc" {
  source_policy_documents = [var.lambda_function_processador_st_modulo_teste_state_doc_extra_statements_json]
  statement {
    sid       = "AllowEventSourceRead"
    effect    = "Allow"
    actions   = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
    resources = [aws_sqs_queue.pedidos.arn]
  }
}

resource "aws_iam_policy" "lambda_function_processador_st_modulo-teste-state" {
  name        = "lambda_function_processador_st_modulo-teste-state"
  description = "Access Policy for processador"
  policy      = data.aws_iam_policy_document.lambda_function_processador_st_modulo-teste-state_doc.json
}

resource "aws_iam_role_policy_attachment" "lambda_function_processador_st_modulo-teste-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_processador_st_modulo-teste-state.arn
  role       = aws_iam_role.processador_role.name
}
