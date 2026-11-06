resource "aws_cloudwatch_log_group" "ingestion-logs" {
  name              = "/aws/lambda/lambda-ingestion"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "ingestion-logs"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "init-db-logs" {
  name              = "/aws/lambda/lambda-init-db"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "init-db-logs"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "presign-logs" {
  name              = "/aws/lambda/lambda-presign"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "presign-logs"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "publisher-logs" {
  name              = "/aws/lambda/lambda-publisher"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "publisher-logs"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "search-logs" {
  name              = "/aws/lambda/lambda-search"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "search-logs"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}
