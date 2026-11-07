data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "modlab-c-fila" {
  name                              = "modlab-c-fila"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "modlab-c-fila"
    State          = "modlab-c"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_modlab-c-fila_st_modlab-c_doc" {
  statement {
    sid    = "AllowSQSActions"
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.modlab-c-fila.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_modlab-c-fila_st_modlab-c" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c_doc.json
  queue_url = aws_sqs_queue.modlab-c-fila.id
}

output "modlab_c_fila_arn" {
  value = aws_sqs_queue.modlab-c-fila.arn
}

output "aws_sqs_queue_policy_modlab_c_fila_st_modlab_c_whole" {
  value = aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
}
