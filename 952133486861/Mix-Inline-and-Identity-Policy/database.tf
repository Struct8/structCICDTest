resource "aws_dynamodb_table" "Table3" {
  name                        = "Table3"
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
    Name           = "Table3"
    State          = "Mix-Inline-and-Identity-Policy"
    Struct8Creator = "rmay struct"
  }
}
