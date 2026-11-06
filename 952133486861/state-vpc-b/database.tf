resource "aws_dynamodb_table" "traffic-table-b" {
  name                        = "traffic-table-b"
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
  tags = {
    Name           = "traffic-table-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}
