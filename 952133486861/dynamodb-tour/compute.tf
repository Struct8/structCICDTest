resource "aws_lambda_event_source_mapping" "LedgerStreamMapping" {
  function_name                      = aws_lambda_function.StreamConsumer.arn
  batch_size                         = 100
  bisect_batch_on_function_error     = false
  event_source_arn                   = aws_dynamodb_table.Ledger.stream_arn
  function_response_types            = ["ReportBatchItemFailures"]
  maximum_batching_window_in_seconds = 5
  maximum_record_age_in_seconds      = -1
  maximum_retry_attempts             = -1
  parallelization_factor             = 1
  starting_position                  = "LATEST"
  tags = {
    Name           = "LedgerStreamMapping"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lambda_function" "StreamConsumer" {
  function_name                  = "StreamConsumer"
  architectures                  = ["arm64"]
  description                    = "Stream consumer running the Struct8 hub (code from Struct8/struct8-hub prebuilt). It reads the Ledger stream via the Event Source Mapping and reports each hop."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 128
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.StreamConsumer_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
      ACCOUNT = "952133486861"
      NAME    = "StreamConsumer"
      REGION  = "us-west-2"
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
    Name           = "StreamConsumer"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_StreamConsumer_st_dynamodb-tour_attach]
}

resource "aws_appautoscaling_policy" "sc_policy_Read_ByEmailAutoscale_Users" {
  name               = "DynamoDBReadCapacityUtilization:sc_target_Read_ByEmailAutoscale_Users"
  resource_id        = aws_appautoscaling_target.sc_target_Read_ByEmailAutoscale_Users.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.sc_target_Read_ByEmailAutoscale_Users.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sc_target_Read_ByEmailAutoscale_Users.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "sc_policy_Read_MetricsAutoscaling" {
  name               = "DynamoDBReadCapacityUtilization:sc_target_Read_MetricsAutoscaling"
  resource_id        = aws_appautoscaling_target.sc_target_Read_MetricsAutoscaling.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.sc_target_Read_MetricsAutoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sc_target_Read_MetricsAutoscaling.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "sc_policy_Write_ByEmailAutoscale_Users" {
  name               = "DynamoDBWriteCapacityUtilization:sc_target_Write_ByEmailAutoscale_Users"
  resource_id        = aws_appautoscaling_target.sc_target_Write_ByEmailAutoscale_Users.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.sc_target_Write_ByEmailAutoscale_Users.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sc_target_Write_ByEmailAutoscale_Users.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "sc_policy_Write_MetricsAutoscaling" {
  name               = "DynamoDBWriteCapacityUtilization:sc_target_Write_MetricsAutoscaling"
  resource_id        = aws_appautoscaling_target.sc_target_Write_MetricsAutoscaling.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.sc_target_Write_MetricsAutoscaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sc_target_Write_MetricsAutoscaling.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70.0
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "sc_target_Read_ByEmailAutoscale_Users" {
  resource_id        = "table/${aws_dynamodb_table.Users.name}/index/ByEmailAutoscale"
  max_capacity       = 10
  min_capacity       = 1
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  tags = {
    Name           = "sc_target_Read_ByEmailAutoscale_Users"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_appautoscaling_target" "sc_target_Read_MetricsAutoscaling" {
  resource_id        = "table/${aws_dynamodb_table.MetricsAutoscaling.name}"
  max_capacity       = 10
  min_capacity       = 1
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
  tags = {
    Name           = "sc_target_Read_MetricsAutoscaling"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_appautoscaling_target" "sc_target_Write_ByEmailAutoscale_Users" {
  resource_id        = "table/${aws_dynamodb_table.Users.name}/index/ByEmailAutoscale"
  max_capacity       = 10
  min_capacity       = 1
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
  tags = {
    Name           = "sc_target_Write_ByEmailAutoscale_Users"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_appautoscaling_target" "sc_target_Write_MetricsAutoscaling" {
  resource_id        = "table/${aws_dynamodb_table.MetricsAutoscaling.name}"
  max_capacity       = 10
  min_capacity       = 1
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
  tags = {
    Name           = "sc_target_Write_MetricsAutoscaling"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}
