resource "aws_dynamodb_kinesis_streaming_destination" "KinesisDestination" {
  table_name = aws_dynamodb_table.Ledger.name
  stream_arn = aws_kinesis_stream.LedgerKinesisStream.arn
}

resource "aws_dynamodb_table" "EventsOnDemand" {
  name                        = "EventsOnDemand"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "EventId"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "EventId"
    type = "S"
  }
  tags = {
    Name           = "EventsOnDemand"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "Ledger" {
  name                        = "Ledger"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "AccountId"
  range_key                   = "TxnId"
  stream_enabled              = true
  stream_view_type            = "NEW_AND_OLD_IMAGES"
  table_class                 = "STANDARD"
  attribute {
    name = "AccountId"
    type = "S"
  }
  attribute {
    name = "TxnId"
    type = "S"
  }
  tags = {
    Name           = "Ledger"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "MetricsAutoscaling" {
  name                        = "MetricsAutoscaling"
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  hash_key                    = "MetricId"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  write_capacity              = 1
  attribute {
    name = "MetricId"
    type = "S"
  }
  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
  tags = {
    Name           = "MetricsAutoscaling"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "Orders" {
  name                        = "Orders"
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  hash_key                    = "OrderId"
  range_key                   = "CreatedAt"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  write_capacity              = 1
  attribute {
    name = "OrderId"
    type = "S"
  }
  attribute {
    name = "CreatedAt"
    type = "S"
  }
  tags = {
    Name           = "Orders"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "RestoredLatest" {
  name                        = "RestoredLatest"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "Id"
  restore_to_latest_time      = true
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "Id"
    type = "S"
  }
  tags = {
    Name           = "RestoredLatest"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "RestoredPointInTime" {
  name                        = "RestoredPointInTime"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "Id"
  restore_date_time           = "2026-01-01T00:00:00Z"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "Id"
    type = "S"
  }
  tags = {
    Name           = "RestoredPointInTime"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table" "Sessions" {
  name                        = "Sessions"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "SessionId"
  stream_enabled              = false
  table_class                 = "STANDARD_INFREQUENT_ACCESS"
  attribute {
    name = "SessionId"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  tags = {
    Name           = "Sessions"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
  ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
  }
}

resource "aws_dynamodb_table" "Users" {
  name                        = "Users"
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  hash_key                    = "UserId"
  range_key                   = "ProfileType"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  write_capacity              = 1
  attribute {
    name = "UserId"
    type = "S"
  }
  attribute {
    name = "ProfileType"
    type = "S"
  }
  attribute {
    name = "Email"
    type = "S"
  }
  attribute {
    name = "Country"
    type = "S"
  }
  attribute {
    name = "Score"
    type = "N"
  }
  attribute {
    name = "Fingerprint"
    type = "B"
  }
  global_secondary_index {
    name            = "ByCountry"
    hash_key        = "Country"
    projection_type = "ALL"
    read_capacity   = 1
    write_capacity  = 1
  }
  global_secondary_index {
    name            = "ByEmailAutoscale"
    hash_key        = "Email"
    projection_type = "KEYS_ONLY"
    read_capacity   = 1
    write_capacity  = 1
  }
  global_secondary_index {
    name               = "ByProfileInclude"
    hash_key           = "ProfileType"
    non_key_attributes = ["Email", "Country"]
    projection_type    = "INCLUDE"
    read_capacity      = 1
    write_capacity     = 1
  }
  local_secondary_index {
    name            = "ByEmail"
    projection_type = "KEYS_ONLY"
    range_key       = "Email"
  }
  local_secondary_index {
    name            = "ByScoreAll"
    projection_type = "ALL"
    range_key       = "Score"
  }
  local_secondary_index {
    name               = "ByFingerprintInclude"
    non_key_attributes = ["Email"]
    projection_type    = "INCLUDE"
    range_key          = "Fingerprint"
  }
  tags = {
    Name           = "Users"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_dynamodb_table_item" "AdminUser" {
  table_name = aws_dynamodb_table.Users.name
  hash_key   = aws_dynamodb_table.Users.hash_key
  item = <<EOF
{
  "UserId": {"S": "USR-7"},
  "ProfileType": {"S": "ADMIN"},
  "Email": {"S": "alice@example.com"},
  "Country": {"S": "BR"},
  "Score": {"N": "980"},
  "Tags": {"SS": ["vip", "beta"]}
}
  EOF
  range_key = aws_dynamodb_table.Users.range_key
}

resource "aws_dynamodb_table_item" "OrderPending" {
  table_name = aws_dynamodb_table.Orders.name
  hash_key   = aws_dynamodb_table.Orders.hash_key
  item = <<EOF
{
  "OrderId": {"S": "ORD-1002"},
  "CreatedAt": {"S": "2026-02-01T08:15:00Z"},
  "Total": {"N": "32.50"},
  "Status": {"S": "PENDING"}
}
  EOF
  range_key = aws_dynamodb_table.Orders.range_key
}

resource "aws_dynamodb_table_item" "OrderShipped" {
  table_name = aws_dynamodb_table.Orders.name
  hash_key   = aws_dynamodb_table.Orders.hash_key
  item = <<EOF
{
  "OrderId": {"S": "ORD-1001"},
  "CreatedAt": {"S": "2026-01-15T10:30:00Z"},
  "Total": {"N": "149.90"},
  "Status": {"S": "SHIPPED"}
}
  EOF
  range_key = aws_dynamodb_table.Orders.range_key
}

resource "aws_dynamodb_table_item" "SignupEvent" {
  table_name = aws_dynamodb_table.EventsOnDemand.name
  hash_key   = aws_dynamodb_table.EventsOnDemand.hash_key
  item = <<EOF
{
  "EventId": {"S": "EVT-abc123"},
  "Type": {"S": "user.signup"},
  "Payload": {"M": {"plan": {"S": "free"}, "referred": {"BOOL": false}}}
}
  EOF
  range_key = aws_dynamodb_table.EventsOnDemand.range_key
}
