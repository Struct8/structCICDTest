resource "aws_kinesis_stream" "LedgerKinesisStream" {
  name                   = "LedgerKinesisStream"
  max_record_size_in_kib = 1024
  shard_count            = 1
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  tags = {
    Name           = "LedgerKinesisStream"
    State          = "dynamodb-tour"
    Struct8Creator = "rmay struct"
  }
}
