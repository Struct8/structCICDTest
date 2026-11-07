resource "aws_cloudwatch_log_group" "processor-logs" {
  name              = "/aws/lambda/processor"
  log_group_class   = "STANDARD"
  retention_in_days = 7
  skip_destroy      = false
  tags = {
    Name           = "processor-logs"
    State          = "modlab-a"
    Struct8Creator = "rmay struct"
  }
}
