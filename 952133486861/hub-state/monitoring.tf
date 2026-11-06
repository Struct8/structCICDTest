resource "aws_cloudwatch_log_group" "hub-fn-logs" {
  name              = "/aws/lambda/hub-fn"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "hub-fn-logs"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "hub-logs" {
  name              = "/aws/ecs/hub"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "hub-logs"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}
