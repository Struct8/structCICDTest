resource "aws_dynamodb_table" "traffic-table-a" {
  name                        = "traffic-table-a"
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
    Name           = "traffic-table-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
  ttl {
    enabled = false
  }
}
