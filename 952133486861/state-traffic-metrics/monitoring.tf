resource "aws_cloudwatch_log_group" "process-flow-logs" {
  name              = "/aws/lambda/process-flow-logs"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "process-flow-logs"
    State          = "state-traffic-metrics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_prometheus_workspace" "vpc-traffic" {
  alias = "vpc-traffic"
  tags = {
    Struct8Management = "Struct8Flow"
    Name              = "vpc-traffic"
    State             = "state-traffic-metrics"
    Struct8Creator    = "rmay struct"
  }
}

resource "aws_prometheus_workspace_configuration" "vpc-traffic_configuration" {
  workspace_id                        = aws_prometheus_workspace.vpc-traffic.id
  out_of_order_time_window_in_seconds = 600
  retention_period_in_days            = 30
  rule_query_offset_in_seconds        = 60
}
