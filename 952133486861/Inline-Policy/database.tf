resource "aws_dynamodb_table" "Table2" {
  name                        = "Table2"
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
    Name           = "Table2"
    State          = "Inline-Policy"
    Struct8Creator = "rmay struct"
  }
}
