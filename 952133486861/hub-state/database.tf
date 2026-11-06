resource "aws_dynamodb_table" "hub-out" {
  name                        = "hub-out"
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
    Name           = "hub-out"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}
