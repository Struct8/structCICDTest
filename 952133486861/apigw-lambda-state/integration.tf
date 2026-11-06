resource "aws_sqs_queue" "jobs" {
  name                              = "jobs"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "jobs"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_kinesis_stream" "events" {
  name        = "events"
  shard_count = 1
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  tags = {
    Name           = "events"
    State          = "apigw-lambda-state"
    Struct8Creator = "rmay struct"
  }
}
