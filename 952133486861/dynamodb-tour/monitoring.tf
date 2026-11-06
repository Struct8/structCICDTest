resource "aws_cloudwatch_log_group" "StreamConsumer" {
  name              = "/aws/lambda/StreamConsumer"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "StreamConsumer"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}
