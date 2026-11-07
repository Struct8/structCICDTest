resource "aws_dynamodb_table" "order-lab-data" {
  name                        = "order-lab-data"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "pk"
  range_key                   = "sk"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "pk"
    type = "S"
  }
  attribute {
    name = "sk"
    type = "S"
  }
  tags = {
    Name           = "order-lab-data"
    State          = "modlab-b"
    Struct8Creator = "rmay struct"
  }
}
