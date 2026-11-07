moved {
  from = aws_sqs_queue.archive
  to   = module.dados.aws_sqs_queue.archive
}

moved {
  from = aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a
  to   = module.dados.aws_sqs_queue_policy.aws_sqs_queue_policy_archive_st_modlab-a
}

moved {
  from = aws_s3_bucket.source
  to   = module.dados.aws_s3_bucket.source
}

moved {
  from = aws_s3_bucket_notification.source-events
  to   = module.dados.aws_s3_bucket_notification.source-events
}

moved {
  from = aws_s3_bucket_public_access_block.source_block
  to   = module.dados.aws_s3_bucket_public_access_block.source_block
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.source_configuration
  to   = module.dados.aws_s3_bucket_server_side_encryption_configuration.source_configuration
}

moved {
  from = aws_s3_bucket_ownership_controls.source_controls
  to   = module.dados.aws_s3_bucket_ownership_controls.source_controls
}

moved {
  from = aws_s3_bucket_versioning.source_versioning
  to   = module.dados.aws_s3_bucket_versioning.source_versioning
}
