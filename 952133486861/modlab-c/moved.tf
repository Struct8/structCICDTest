moved {
  from = module.mensagens.aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
  to   = module.mensageria.aws_sqs_queue_policy.aws_sqs_queue_policy_modlab-c-fila_st_modlab-c
}

moved {
  from = module.mensagens.aws_s3_bucket.modlab-c-balde
  to   = module.mensageria.aws_s3_bucket.modlab-c-balde
}

moved {
  from = module.mensagens.aws_s3_bucket_public_access_block.modlab-c-balde_block
  to   = module.mensageria.aws_s3_bucket_public_access_block.modlab-c-balde_block
}

moved {
  from = module.mensagens.aws_s3_bucket_server_side_encryption_configuration.modlab-c-balde_configuration
  to   = module.mensageria.aws_s3_bucket_server_side_encryption_configuration.modlab-c-balde_configuration
}

moved {
  from = module.mensagens.aws_s3_bucket_ownership_controls.modlab-c-balde_controls
  to   = module.mensageria.aws_s3_bucket_ownership_controls.modlab-c-balde_controls
}

moved {
  from = module.mensagens.aws_s3_bucket_versioning.modlab-c-balde_versioning
  to   = module.mensageria.aws_s3_bucket_versioning.modlab-c-balde_versioning
}

moved {
  from = module.mensagens.aws_sqs_queue.modlab-c-fila
  to   = module.mensageria.aws_sqs_queue.modlab-c-fila
}
