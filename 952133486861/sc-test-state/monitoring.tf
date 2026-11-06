resource "aws_cloudwatch_log_group" "client-test-logs" {
  name              = "/aws/ecs/sc-client"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "client-test-logs"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "server-test-logs" {
  name              = "/aws/ecs/sc-server"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "server-test-logs"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}
