resource "aws_lambda_function" "wp-process-flow-logs" {
  function_name                  = "wp-process-flow-logs"
  architectures                  = ["arm64"]
  description                    = "Reads each VPC Flow Logs object delivered to the bucket and writes bytes and packets per conversation per minute to the Prometheus workspace."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "ProcessFlowLogs.lambda_handler"
  memory_size                    = 2024
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.wp-process-flow-logs_role.arn
  runtime                        = "python3.13"
  timeout                        = 120
  environment {
    variables = {
      ACCOUNT                             = "952133486861"
      AWS_PROMETHEUS_WORKSPACE_ENDPOINT_0 = "https://aps-workspaces.us-west-2.amazonaws.com/workspaces/ws-077cc2ba-ffde-47f5-9269-a7e1f3e29ca4/"
      AWS_PROMETHEUS_WORKSPACE_ID_0       = "ws-077cc2ba-ffde-47f5-9269-a7e1f3e29ca4"
      AWS_S3_BUCKET_NAME_0                = "flowlogs-bucket-952133486861-us-west-2-an"
      BUCKET_SECONDS                      = "60"
      CUTOFF_SECONDS                      = "120"
      FALLBACK_FIELD_ORDER                = "version vpc-id subnet-id interface-id instance-id srcaddr dstaddr pkt-srcaddr pkt-dstaddr srcport dstport protocol packets bytes start end action log-status flow-direction traffic-path pkt-src-aws-service pkt-dst-aws-service interface-type"
      FLOW_LOG_BUCKET                     = "flowlogs-bucket-952133486861-us-west-2-an"
      NAME                                = "wp-process-flow-logs"
      REGION                              = "us-west-2"
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
    Name           = "wp-process-flow-logs"
    State          = "wp-flowlogs"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_wp-process-flow-logs_st_wp-flowlogs_attach_wp-process-flow-logs_role]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_flowlogs-bucket_to_wp-process-flow-logs" {
  function_name = aws_lambda_function.wp-process-flow-logs.function_name
  statement_id  = "perm_aws_s3_bucket_flowlogs-bucket_to_wp-process-flow-logs2148f78c5beea787f6e6c2ed81"
  principal     = "s3.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_s3_bucket.flowlogs-bucket.arn
}
