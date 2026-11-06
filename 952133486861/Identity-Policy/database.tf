resource "aws_dynamodb_table" "Table1" {
  name                        = "Table1"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "ID"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "ID"
    type = "S"
  }
  tags = {
    Name           = "Table1"
    State          = "Identity-Policy"
    Struct8Creator = "rmay struct"
  }
}
