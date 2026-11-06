resource "aws_lambda_event_source_mapping" "ingestion-esm" {
  function_name                      = aws_lambda_function.lambda-ingestion.arn
  batch_size                         = 10
  event_source_arn                   = aws_sqs_queue.ingestion-queue.arn
  function_response_types            = ["ReportBatchItemFailures"]
  maximum_batching_window_in_seconds = 5
  tags = {
    Name           = "ingestion-esm"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lambda_function" "lambda-ingestion" {
  function_name                  = "lambda-ingestion"
  architectures                  = ["arm64"]
  description                    = "Worker de ingestao: grava produto e indexa (tsvector/embeddings) no Aurora via RDS Proxy"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 1024
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-ingestion_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 60
  environment {
    variables = {
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:products-aurora"
      AWS_RDS_CLUSTER_DATA_API_0   = true
      AWS_RDS_CLUSTER_DB_NAME_0    = "produtos"
      AWS_RDS_CLUSTER_ENDPOINT_0   = "products-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
      AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
      AWS_RDS_CLUSTER_NAME_0       = "products-aurora"
      AWS_RDS_CLUSTER_PORT_0       = "5432"
      AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-6788012a-6256-4b26-a1a1-d42699e4aede-sWTR33"
      NAME                         = "lambda-ingestion"
      REGION                       = data.aws_region.current.region
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
    Name           = "lambda-ingestion"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-ingestion_st_products-search-state_attach]
}

resource "aws_lambda_function" "lambda-init-db" {
  function_name                  = "lambda-init-db"
  architectures                  = ["arm64"]
  description                    = "Inicializa o schema e popula produtos de exemplo apos o apply"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-init-db_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 60
  environment {
    variables = {
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:products-aurora"
      AWS_RDS_CLUSTER_DATA_API_0   = true
      AWS_RDS_CLUSTER_DB_NAME_0    = "produtos"
      AWS_RDS_CLUSTER_ENDPOINT_0   = "products-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
      AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
      AWS_RDS_CLUSTER_NAME_0       = "products-aurora"
      AWS_RDS_CLUSTER_PORT_0       = "5432"
      AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-6788012a-6256-4b26-a1a1-d42699e4aede-sWTR33"
      NAME                         = "lambda-init-db"
      REGION                       = data.aws_region.current.region
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
    Name           = "lambda-init-db"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-init-db_st_products-search-state_attach]
}

resource "aws_lambda_function" "lambda-presign" {
  function_name                  = "lambda-presign"
  architectures                  = ["arm64"]
  description                    = "Gera presigned PUT para upload de imagem direto no S3"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-presign_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0 = "static-site-952133486861-us-west-2-an"
      NAME                 = "lambda-presign"
      REGION               = data.aws_region.current.region
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
    Name           = "lambda-presign"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-presign_st_products-search-state_attach]
}

resource "aws_lambda_function" "lambda-publisher" {
  function_name                  = "lambda-publisher"
  architectures                  = ["arm64"]
  description                    = "Recebe POST /produtos e publica na SQS para ingestao assincrona"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-publisher_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_SQS_QUEUE_NAME_0 = "ingestion-queue"
      NAME                 = "lambda-publisher"
      REGION               = data.aws_region.current.region
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
    Name           = "lambda-publisher"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-publisher_st_products-search-state_attach]
}

resource "aws_lambda_function" "lambda-search" {
  function_name                  = "lambda-search"
  architectures                  = ["arm64"]
  description                    = "Endpoint de busca: FTS + pg_trgm no Aurora via RDS Data API"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 512
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-search_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 15
  environment {
    variables = {
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:products-aurora"
      AWS_RDS_CLUSTER_DATA_API_0   = true
      AWS_RDS_CLUSTER_DB_NAME_0    = "produtos"
      AWS_RDS_CLUSTER_ENDPOINT_0   = "products-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
      AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
      AWS_RDS_CLUSTER_NAME_0       = "products-aurora"
      AWS_RDS_CLUSTER_PORT_0       = "5432"
      AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-6788012a-6256-4b26-a1a1-d42699e4aede-sWTR33"
      NAME                         = "lambda-search"
      REGION                       = data.aws_region.current.region
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
    Name           = "lambda-search"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-search_st_products-search-state_attach]
}

resource "aws_lambda_invocation" "init-db-invocation" {
  function_name = aws_lambda_function.lambda-init-db.function_name
  input         = "{}"
  triggers = {
    rds_cluster          = "products-aurora"
    rds_cluster_instance = "products-aurora-instance"
  }
  depends_on = [time_sleep.init-db-invocation_role_propagation]
}

resource "aws_lambda_permission" "perm_aws_apigatewayv2_api_products-http-api_to_lambda-presign" {
  function_name       = aws_lambda_function.lambda-presign.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_apigatewayv2_api.products-http-api.execution_arn}/*/*"
  statement_id_prefix = "perm_aws_apigatewayv2_api_products-http-api_to_lambda-presign"
}

resource "aws_lambda_permission" "perm_aws_apigatewayv2_api_products-http-api_to_lambda-publisher" {
  function_name       = aws_lambda_function.lambda-publisher.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_apigatewayv2_api.products-http-api.execution_arn}/*/*"
  statement_id_prefix = "perm_aws_apigatewayv2_api_products-http-api_to_lambda-publisher"
}

resource "aws_lambda_permission" "perm_aws_apigatewayv2_api_products-http-api_to_lambda-search" {
  function_name       = aws_lambda_function.lambda-search.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_apigatewayv2_api.products-http-api.execution_arn}/*/*"
  statement_id_prefix = "perm_aws_apigatewayv2_api_products-http-api_to_lambda-search"
}
