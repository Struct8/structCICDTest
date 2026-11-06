resource "aws_sqs_queue" "Queue3" {
  name                              = "Queue3"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "Queue3"
    State          = "Inline-Policy"
    Struct8Creator = "rmay struct"
  }
}
