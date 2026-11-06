resource "aws_lambda_function" "process-flow-logs" {
  function_name                  = "process-flow-logs"
  architectures                  = ["arm64"]
  description                    = "Turns each VPC flow log object delivered to flowlogs-bucket into bytes and packets per conversation per minute, and writes them to the vpc-traffic workspace. Names each end by its Name tag."
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "ProcessFlowLogs.lambda_handler"
  memory_size                    = 512
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.process-flow-logs_role.arn
  runtime                        = "python3.13"
  timeout                        = 120
  environment {
    variables = {
      ACCOUNT                             = "952133486861"
      AWS_PROMETHEUS_WORKSPACE_ENDPOINT_0 = "https://aps-workspaces.us-west-2.amazonaws.com/workspaces/ws-b77166c0-58b0-431a-bd69-37bb1e2d794f/"
      AWS_PROMETHEUS_WORKSPACE_ID_0       = "ws-b77166c0-58b0-431a-bd69-37bb1e2d794f"
      AWS_S3_BUCKET_NAME_0                = "flowlogs-bucket-952133486861-us-west-2-an"
      BUCKET_SECONDS                      = "60"
      FALLBACK_FIELD_ORDER                = "version vpc-id subnet-id interface-id instance-id srcaddr dstaddr pkt-srcaddr pkt-dstaddr srcport dstport protocol packets bytes start end action log-status flow-direction traffic-path pkt-src-aws-service pkt-dst-aws-service interface-type"
      FLOW_LOG_BUCKET                     = "flowlogs-bucket-952133486861-us-west-2-an"
      NAME                                = "process-flow-logs"
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
    Name           = "process-flow-logs"
    State          = "state-traffic-metrics"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_process-flow-logs_st_state-traffic-metrics_attach]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_flowlogs-bucket_to_process-flow-logs" {
  function_name = aws_lambda_function.process-flow-logs.function_name
  statement_id  = "perm_aws_s3_bucket_flowlogs-bucket_to_process-flow-logsb1cb727431a6e5e3193898cfc9"
  principal     = "s3.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_s3_bucket.flowlogs-bucket.arn
}
