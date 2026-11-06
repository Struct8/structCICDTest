data "archive_file" "archive_struct8-templates_process-flow-logs" {
  output_path = "${path.module}/struct8-templates_process-flow-logs.zip"
  source_dir  = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/lambda/process-flow-logs"
  type        = "zip"
}

resource "aws_lambda_function" "process-flow-logs" {
  function_name                  = "process-flow-logs"
  architectures                  = ["arm64"]
  description                    = "Turns each VPC flow log object delivered to flowlogs-bucket into bytes and packets per conversation per minute, and writes them to the vpc-traffic workspace. Names each end by its Name tag."
  filename                       = data.archive_file.archive_struct8-templates_process-flow-logs.output_path
  handler                        = "ProcessFlowLogs.lambda_handler"
  memory_size                    = 512
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.process-flow-logs_role.arn
  runtime                        = "python3.13"
  source_code_hash               = data.archive_file.archive_struct8-templates_process-flow-logs.output_base64sha256
  timeout                        = 120
  environment {
    variables = {
      FLOW_LOG_BUCKET                     = aws_s3_bucket.flowlogs-bucket.id
      BUCKET_SECONDS                      = "60"
      FALLBACK_FIELD_ORDER                = "version vpc-id subnet-id interface-id instance-id srcaddr dstaddr pkt-srcaddr pkt-dstaddr srcport dstport protocol packets bytes start end action log-status flow-direction traffic-path pkt-src-aws-service pkt-dst-aws-service interface-type"
      NAME                                = "process-flow-logs"
      REGION                              = data.aws_region.current.region
      ACCOUNT                             = data.aws_caller_identity.current.account_id
      AWS_PROMETHEUS_WORKSPACE_ENDPOINT_0 = aws_prometheus_workspace.vpc-traffic.prometheus_endpoint
      AWS_PROMETHEUS_WORKSPACE_ID_0       = aws_prometheus_workspace.vpc-traffic.id
      AWS_S3_BUCKET_NAME_0                = "flowlogs-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
    }
  }
  tags = {
    Name           = "process-flow-logs"
    State          = "state-traffic-metrics"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_process-flow-logs_st_state-traffic-metrics_attach]
}

resource "aws_lambda_permission" "perm_aws_s3_bucket_flowlogs-bucket_to_process-flow-logs" {
  function_name       = aws_lambda_function.process-flow-logs.function_name
  principal           = "s3.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_s3_bucket.flowlogs-bucket.arn
  statement_id_prefix = "perm_aws_s3_bucket_flowlogs-bucket_to_process-flow-logs"
}
