resource "aws_cloudwatch_log_group" "LogGroup" {
  name              = "/aws/rds/proxy/demo-postgres-proxy"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "LogGroup"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-api-logs" {
  name              = "/aws/lambda/demo-postgres-api"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "demo-postgres-api-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-direct-logs" {
  name              = "/aws/lambda/demo-postgres-direct"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "demo-postgres-direct-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-iam-logs" {
  name              = "/aws/lambda/demo-postgres-iam"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  skip_destroy      = false
  tags = {
    Name           = "demo-postgres-iam-logs"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-postgres-log1" {
  name              = "RDSOSMetrics"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  skip_destroy      = false
  tags = {
    Name           = "demo-postgres-log1"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}
