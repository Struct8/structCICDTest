resource "aws_kinesis_stream" "LedgerKinesisStream" {
  name        = "LedgerKinesisStream"
  shard_count = 1
  tags = {
    Name           = "LedgerKinesisStream"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}
