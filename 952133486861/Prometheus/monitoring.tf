resource "aws_cloudwatch_log_group" "process-flow-logs" {
  name              = "/aws/lambda/process-flow-logs"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "process-flow-logs"
    State          = "Prometheus"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_prometheus_workspace" "flowlogs-amp" {
  alias = "flowlogs-amp"
  tags = {
    Struct8Management = "Struct8Flow"
    Name              = "flowlogs-amp"
    State             = "Prometheus"
    Struct8Creator    = "rmay struct"
  }
}

resource "aws_prometheus_workspace_configuration" "flowlogs-amp_configuration" {
  workspace_id                        = aws_prometheus_workspace.flowlogs-amp.id
  out_of_order_time_window_in_seconds = 600
  retention_period_in_days            = 30
  rule_query_offset_in_seconds        = 60
}
