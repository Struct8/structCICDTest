resource "aws_cloudwatch_log_group" "demo-handler-logs" {
  name              = "/aws/lambda/demo-handler"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "demo-handler-logs"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}
