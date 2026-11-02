resource "aws_dynamodb_table" "orders-table" {
  name                        = "orders-table"
  billing_mode                = "PROVISIONED"
  deletion_protection_enabled = false
  hash_key                    = "ID"
  read_capacity               = 1
  stream_enabled              = false
  table_class                 = "STANDARD"
  write_capacity              = 1
  attribute {
    name = "ID"
    type = "S"
  }
  point_in_time_recovery {
    enabled = false
  }
  tags = {
    Name           = "orders-table"
    State          = "serverless-xray"
    Struct8Creator = "rmay struct"
  }
  ttl {
    enabled = false
  }
}
