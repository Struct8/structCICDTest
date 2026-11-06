resource "aws_sqs_queue" "ingestion-queue" {
  name                              = "ingestion-queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 1209600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 360
  tags = {
    Name           = "ingestion-queue"
    State          = "products-search-state"
    Struct8Creator = "rmay struct"
  }
}
