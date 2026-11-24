resource "aws_lambda_function" "analyticsPage" {
  function_name                  = "analyticsPage"
  architectures                  = ["arm64"]
  description                    = "Analytics page: runs the CDN log queries in Athena and returns HTML."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 1900
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.analyticsPage_role.arn
  runtime                        = "python3.13"
  timeout                        = 60
  environment {
    variables = {
      ACCESS_KEY                     = "33wXNt6Q9G_CruKz_VHEZmJ-_ZXFQA6B"
      ACCOUNT                        = data.aws_caller_identity.current.account_id
      ATHENA_WORKGROUP               = "cdnAnalytics"
      AWS_ATHENA_WORKGROUP_NAME_0    = "cdnAnalytics"
      AWS_DYNAMODB_TABLE_NAME_0      = "cspTable"
      AWS_GLUE_CATALOG_TABLE_NAME_0  = "cdn_log"
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "analyticsUrl"
      AWS_S3_BUCKET_NAME_0           = "cdnlogbucket-952133486861-us-west-2-an"
      AWS_XRAY_GROUP_NAME_0          = "analyticsTraces"
      GLUE_DATABASE                  = "cdn_analytics"
      GLUE_TABLE                     = "cdn_log"
      NAME                           = "analyticsPage"
      REGION                         = data.aws_region.current.region
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
    Name           = "analyticsPage"
    State          = "impWpAnalytics"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_analyticsPage_st_wp-analytics_attach_analyticsPage_role]
}

resource "aws_lambda_function" "cspReceiver" {
  function_name                  = "cspReceiver"
  architectures                  = ["arm64"]
  description                    = "Receives CSP violation reports from browsers and counts them in cspTable."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 256
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.cspReceiver_role.arn
  runtime                        = "python3.13"
  timeout                        = 10
  environment {
    variables = {
      ACCOUNT                        = data.aws_caller_identity.current.account_id
      AWS_DYNAMODB_TABLE_NAME_0      = "cspTable"
      AWS_LAMBDA_FUNCTION_URL_NAME_0 = "cspReceiverUrl"
      AWS_XRAY_GROUP_NAME_0          = "analyticsTraces"
      NAME                           = "cspReceiver"
      REGION                         = data.aws_region.current.region
      SITE_HOST                      = "wp.cloudman.pro"
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
    Name           = "cspReceiver"
    State          = "impWpAnalytics"
    Struct8Creator = "rmay struct"
  }
  tracing_config {
    mode = "Active"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_cspReceiver_st_wp-analytics_attach_cspReceiver_role]
}

resource "aws_lambda_function_url" "analyticsUrl" {
  function_name      = aws_lambda_function.analyticsPage.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_lambda_function_url" "cspReceiverUrl" {
  function_name      = aws_lambda_function.cspReceiver.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_cspReceiverUrl_to_cspReceiver" {
  function_name          = aws_lambda_function.cspReceiver.function_name
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  statement_id_prefix    = "perm_aws_lambda_function_url_cspReceiverUrl_to_cspReceiver"
  depends_on             = [aws_lambda_function_url.cspReceiverUrl]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_cspReceiverUrl_to_cspReceiver_invoke" {
  function_name            = aws_lambda_function.cspReceiver.function_name
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  statement_id_prefix      = "perm_aws_lambda_function_url_cspReceiverUrl_to_cspReceiver_invoke"
  depends_on               = [aws_lambda_function_url.cspReceiverUrl, aws_lambda_permission.perm_aws_lambda_function_url_cspReceiverUrl_to_cspReceiver]
}

resource "aws_appautoscaling_policy" "sc_policy_Read_cspTable" {
  name               = "DynamoDBReadCapacityUtilization:sc_target_Read_cspTable"
  resource_id        = aws_appautoscaling_target.sc_target_Read_cspTable.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.sc_target_Read_cspTable.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sc_target_Read_cspTable.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "sc_target_Read_cspTable" {
  resource_id        = "table/${aws_dynamodb_table.cspTable.name}"
  max_capacity       = 20
  min_capacity       = 5
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  tags = {
    Name           = "sc_target_Read_cspTable"
    State          = "impWpAnalytics"
    Struct8Creator = "rmay struct"
  }
}
