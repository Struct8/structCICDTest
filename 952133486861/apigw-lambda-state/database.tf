resource "aws_dynamodb_table" "items" {
  name                        = "items"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "id"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Name           = "items"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}
