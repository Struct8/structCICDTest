resource "aws_cloudwatch_log_group" "analyticsPageLogs" {
  name              = "/aws/lambda/analyticsPage"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "analyticsPageLogs"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "cspReceiverLogs" {
  name              = "/aws/lambda/cspReceiver"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  tags = {
    Name           = "cspReceiverLogs"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_xray_group" "analyticsTraces" {
  group_name        = "analyticsTraces"
  filter_expression = "service(\"analyticsPage\") OR service(\"cspReceiver\")"
  insights_configuration {
    insights_enabled      = false
    notifications_enabled = false
  }
  tags = {
    Name           = "analyticsTraces"
    State          = "wp-analytics"
    Struct8Creator = "rmay struct"
  }
}
