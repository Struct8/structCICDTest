moved {
  from = aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
  to   = module.mensagens.aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
}

moved {
  from = aws_s3_bucket.modlab-c-balde
  to   = module.mensagens.aws_s3_bucket.modlab-c-balde
}

moved {
  from = aws_s3_bucket_public_access_block.modlab-c-balde_block
  to   = module.mensagens.aws_s3_bucket_public_access_block.modlab-c-balde_block
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.modlab-c-balde_configuration
  to   = module.mensagens.aws_s3_bucket_server_side_encryption_configuration.modlab-c-balde_configuration
}

moved {
  from = aws_s3_bucket_ownership_controls.modlab-c-balde_controls
  to   = module.mensagens.aws_s3_bucket_ownership_controls.modlab-c-balde_controls
}

moved {
  from = aws_s3_bucket_versioning.modlab-c-balde_versioning
  to   = module.mensagens.aws_s3_bucket_versioning.modlab-c-balde_versioning
}

moved {
  from = aws_sqs_queue.modlab-c-fila
  to   = module.mensagens.aws_sqs_queue.modlab-c-fila
}
