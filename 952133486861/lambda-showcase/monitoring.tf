resource "aws_cloudwatch_log_group" "worker-logs" {
  name              = "/aws/lambda/worker"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  tags = {
    Name           = "worker-logs"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}
