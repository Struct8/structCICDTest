resource "aws_cloudwatch_log_group" "ProcessCUR" {
  name              = "/aws/lambda/ProcessCUR"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "ProcessCUR"
    State          = "CostUsageReport"
    Struct8Creator = "rmay struct"
  }
}
