resource "aws_cloudwatch_log_group" "ProcessCUR" {
  name              = "/aws/lambda/ProcessCUR"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "ProcessCUR"
    State          = "CostUsageReport"
    Struct8Creator = "rmay struct"
  }
}
