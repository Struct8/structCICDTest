resource "aws_lambda_event_source_mapping" "sqs-to-worker" {
  function_name           = aws_lambda_function.async-worker.arn
  batch_size              = 10
  event_source_arn        = aws_sqs_queue.order-processing.arn
  function_response_types = ["ReportBatchItemFailures"]
  tags = {
    Name           = "sqs-to-worker"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
}

data "archive_file" "archive_struct8-hub_api-handler" {
  output_path = "${path.module}/struct8-hub_api-handler.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "api-handler" {
  function_name                  = "api-handler"
  architectures                  = ["arm64"]
  description                    = "[Step 2/8] Sync handler behind API Gateway, X-Ray instrumented. Per request: (3) writes to DynamoDB and (4) publishes to SNS, injecting the trace header so the async side stays on the same trace. Returns 200."
  filename                       = data.archive_file.archive_struct8-hub_api-handler.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.api-handler_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_api-handler.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                      = "api-handler"
      REGION                    = data.aws_region.current.region
      ACCOUNT                   = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0 = "orders-table"
      AWS_SNS_TOPIC_NAME_0      = "order-events"
      AWS_XRAY_GROUP_NAME_0     = "serverless-demo-traces"
    }
  }
  tags = {
    Name           = "api-handler"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_api-handler_st_serverless-xray_attach]
}

data "archive_file" "archive_struct8-hub_async-worker" {
  output_path = "${path.module}/struct8-hub_async-worker.zip"
  source_dir  = "${path.module}/.external_modules/struct8-hub/prebuilt"
  type        = "zip"
}

resource "aws_lambda_function" "async-worker" {
  function_name                  = "async-worker"
  architectures                  = ["arm64"]
  description                    = "[Step 7/8] Async worker, invoked by the event source mapping. X-Ray instrumented: reads the AWSTraceHeader from the SQS message to continue the original trace, then (8) writes the result to S3."
  filename                       = data.archive_file.archive_struct8-hub_async-worker.output_path
  handler                        = "index.handler"
  memory_size                    = 3008
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.async-worker_role.arn
  runtime                        = "nodejs22.x"
  source_code_hash               = data.archive_file.archive_struct8-hub_async-worker.output_base64sha256
  timeout                        = 30
  environment {
    variables = {
      NAME                  = "async-worker"
      REGION                = data.aws_region.current.region
      ACCOUNT               = data.aws_caller_identity.current.account_id
      AWS_S3_BUCKET_NAME_0  = "order-results-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
      AWS_XRAY_GROUP_NAME_0 = "serverless-demo-traces"
    }
  }
  tags = {
    Name           = "async-worker"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_async-worker_st_serverless-xray_attach]
}

resource "aws_lambda_permission" "perm_aws_api_gateway_rest_api_xray-demo-api_to_api-handler_orders-post" {
  function_name       = aws_lambda_function.api-handler.function_name
  principal           = "apigateway.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = "${aws_api_gateway_rest_api.xray-demo-api.execution_arn}/*/POST${aws_api_gateway_resource.orders.path}"
  statement_id_prefix = "perm_aws_api_gateway_rest_api_xray-demo-api_to_api-handler_orders-post"
}
