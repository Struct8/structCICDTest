resource "aws_cloudwatch_log_group" "mysql-logs-audit" {
  name              = "/aws/rds/instance/demo-mysql/audit"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "mysql-logs-audit"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "mysql-logs-error" {
  name              = "/aws/rds/instance/demo-mysql/error"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "mysql-logs-error"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "mysql-logs-general" {
  name              = "/aws/rds/instance/demo-mysql/general"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "mysql-logs-general"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "mysql-logs-monitoring" {
  name              = "RDSOSMetrics"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "mysql-logs-monitoring"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "mysql-logs-slowquery" {
  name              = "/aws/rds/instance/demo-mysql/slowquery"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "mysql-logs-slowquery"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}
