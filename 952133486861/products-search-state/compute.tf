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

data "archive_file" "archive_CloudMan_lambda-ingestion" {
  output_path = "${path.module}/CloudMan_lambda-ingestion.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/produtos-search/ingestao"
  type        = "zip"
}

resource "aws_lambda_function" "lambda-ingestion" {
  function_name                  = "lambda-ingestion"
  architectures                  = ["arm64"]
  description                    = "Worker de ingestao: grava produto e indexa (tsvector/embeddings) no Aurora via RDS Proxy"
  filename                       = data.archive_file.archive_CloudMan_lambda-ingestion.output_path
  handler                        = "index.handler"
  memory_size                    = 1024
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-ingestion_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_CloudMan_lambda-ingestion.output_base64sha256
  timeout                        = 60
  environment {
    variables = {
      NAME                         = "lambda-ingestion"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_NAME_0       = aws_rds_cluster.products-aurora.cluster_identifier
      AWS_RDS_CLUSTER_ENGINE_0     = aws_rds_cluster.products-aurora.engine
      AWS_RDS_CLUSTER_ENDPOINT_0   = aws_rds_cluster.products-aurora.endpoint
      AWS_RDS_CLUSTER_PORT_0       = aws_rds_cluster.products-aurora.port
      AWS_RDS_CLUSTER_DB_NAME_0    = coalesce(aws_rds_cluster.products-aurora.database_name, "postgres")
      AWS_RDS_CLUSTER_SECRET_ARN_0 = one(aws_rds_cluster.products-aurora.master_user_secret[*].secret_arn)
      AWS_RDS_CLUSTER_ARN_0        = aws_rds_cluster.products-aurora.arn
      AWS_RDS_CLUSTER_DATA_API_0   = true
    }
  }
  tags = {
    Name           = "lambda-ingestion"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-ingestion_st_products-search-state_attach]
}

data "archive_file" "archive_CloudMan_lambda-init-db" {
  output_path = "${path.module}/CloudMan_lambda-init-db.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/produtos-search/init-db"
  type        = "zip"
}

resource "aws_lambda_function" "lambda-init-db" {
  function_name                  = "lambda-init-db"
  architectures                  = ["arm64"]
  description                    = "Inicializa o schema e popula produtos de exemplo apos o apply"
  filename                       = data.archive_file.archive_CloudMan_lambda-init-db.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-init-db_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_CloudMan_lambda-init-db.output_base64sha256
  timeout                        = 60
  environment {
    variables = {
      NAME                         = "lambda-init-db"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_NAME_0       = aws_rds_cluster.products-aurora.cluster_identifier
      AWS_RDS_CLUSTER_ENGINE_0     = aws_rds_cluster.products-aurora.engine
      AWS_RDS_CLUSTER_ENDPOINT_0   = aws_rds_cluster.products-aurora.endpoint
      AWS_RDS_CLUSTER_PORT_0       = aws_rds_cluster.products-aurora.port
      AWS_RDS_CLUSTER_DB_NAME_0    = coalesce(aws_rds_cluster.products-aurora.database_name, "postgres")
      AWS_RDS_CLUSTER_SECRET_ARN_0 = one(aws_rds_cluster.products-aurora.master_user_secret[*].secret_arn)
      AWS_RDS_CLUSTER_ARN_0        = aws_rds_cluster.products-aurora.arn
      AWS_RDS_CLUSTER_DATA_API_0   = true
    }
  }
  tags = {
    Name           = "lambda-init-db"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-init-db_st_products-search-state_attach]
}

data "archive_file" "archive_CloudMan_lambda-presign" {
  output_path = "${path.module}/CloudMan_lambda-presign.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/produtos-search/presign"
  type        = "zip"
}

resource "aws_lambda_function" "lambda-presign" {
  function_name                  = "lambda-presign"
  architectures                  = ["arm64"]
  description                    = "Gera presigned PUT para upload de imagem direto no S3"
  filename                       = data.archive_file.archive_CloudMan_lambda-presign.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-presign_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_CloudMan_lambda-presign.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                 = "lambda-presign"
      REGION               = data.aws_region.current.region
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0 = "static-site-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
    }
  }
  tags = {
    Name           = "lambda-presign"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-presign_st_products-search-state_attach]
}

data "archive_file" "archive_CloudMan_lambda-publisher" {
  output_path = "${path.module}/CloudMan_lambda-publisher.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/produtos-search/publisher"
  type        = "zip"
}

resource "aws_lambda_function" "lambda-publisher" {
  function_name                  = "lambda-publisher"
  architectures                  = ["arm64"]
  description                    = "Recebe POST /produtos e publica na SQS para ingestao assincrona"
  filename                       = data.archive_file.archive_CloudMan_lambda-publisher.output_path
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-publisher_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_CloudMan_lambda-publisher.output_base64sha256
  timeout                        = 10
  environment {
    variables = {
      NAME                 = "lambda-publisher"
      REGION               = data.aws_region.current.region
      ACCOUNT              = data.aws_caller_identity.current.account_id
      AWS_SQS_QUEUE_NAME_0 = "ingestion-queue"
    }
  }
  tags = {
    Name           = "lambda-publisher"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_lambda-publisher_st_products-search-state_attach]
}

data "archive_file" "archive_CloudMan_lambda-search" {
  output_path = "${path.module}/CloudMan_lambda-search.zip"
  source_dir  = "${path.module}/.external_modules/CloudMan/LambdaFiles/produtos-search/busca"
  type        = "zip"
}

resource "aws_lambda_function" "lambda-search" {
  function_name                  = "lambda-search"
  architectures                  = ["arm64"]
  description                    = "Endpoint de busca: FTS + pg_trgm no Aurora via RDS Data API"
  filename                       = data.archive_file.archive_CloudMan_lambda-search.output_path
  handler                        = "index.handler"
  memory_size                    = 512
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.lambda-search_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_CloudMan_lambda-search.output_base64sha256
  timeout                        = 15
  environment {
    variables = {
      NAME                         = "lambda-search"
      REGION                       = data.aws_region.current.region
      ACCOUNT                      = data.aws_caller_identity.current.account_id
      AWS_RDS_CLUSTER_NAME_0       = aws_rds_cluster.products-aurora.cluster_identifier
      AWS_RDS_CLUSTER_ENGINE_0     = aws_rds_cluster.products-aurora.engine
      AWS_RDS_CLUSTER_ENDPOINT_0   = aws_rds_cluster.products-aurora.endpoint
      AWS_RDS_CLUSTER_PORT_0       = aws_rds_cluster.products-aurora.port
      AWS_RDS_CLUSTER_DB_NAME_0    = coalesce(aws_rds_cluster.products-aurora.database_name, "postgres")
      AWS_RDS_CLUSTER_SECRET_ARN_0 = one(aws_rds_cluster.products-aurora.master_user_secret[*].secret_arn)
      AWS_RDS_CLUSTER_ARN_0        = aws_rds_cluster.products-aurora.arn
      AWS_RDS_CLUSTER_DATA_API_0   = true
    }
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
    rds_cluster          = aws_rds_cluster.products-aurora.id
    rds_cluster_instance = aws_rds_cluster_instance.products-aurora-instance.id
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
