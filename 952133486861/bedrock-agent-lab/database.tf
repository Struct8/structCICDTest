resource "aws_dynamodb_table" "agent-lab-orders" {
  name                        = "agent-lab-orders"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "order_id"
  stream_enabled              = false
  table_class                 = "STANDARD"
  attribute {
    name = "order_id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = false
  }
  tags = {
    Name           = "agent-lab-orders"
    State          = "bedrock-agent-lab"
    Struct8Creator = "rmay struct"
  }
  ttl {
    enabled = false
  }
}

resource "aws_dynamodb_table_item" "order-1001" {
  table_name = aws_dynamodb_table.agent-lab-orders.name
  hash_key   = aws_dynamodb_table.agent-lab-orders.hash_key
  item = <<EOF
{"eta":{"S":"2026-10-08"},"items":{"S":"2 coffee mugs"},"order_id":{"S":"1001"},"status":{"S":"SHIPPED"}}
  EOF
  range_key = aws_dynamodb_table.agent-lab-orders.range_key
}

resource "aws_dynamodb_table_item" "order-1002" {
  table_name = aws_dynamodb_table.agent-lab-orders.name
  hash_key   = aws_dynamodb_table.agent-lab-orders.hash_key
  item = <<EOF
{"eta":{"S":"2026-10-12"},"items":{"S":"1 desk lamp"},"order_id":{"S":"1002"},"status":{"S":"PROCESSING"}}
  EOF
  range_key = aws_dynamodb_table.agent-lab-orders.range_key
}

resource "aws_dynamodb_table_item" "order-1003" {
  table_name = aws_dynamodb_table.agent-lab-orders.name
  hash_key   = aws_dynamodb_table.agent-lab-orders.hash_key
  item = <<EOF
{"delivered_on":{"S":"2026-10-01"},"items":{"S":"3 notebooks"},"order_id":{"S":"1003"},"status":{"S":"DELIVERED"}}
  EOF
  range_key = aws_dynamodb_table.agent-lab-orders.range_key
}
