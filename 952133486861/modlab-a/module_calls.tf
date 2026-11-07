module "dados" {
  source                                     = "./modules/dados"
  processor_arn                              = aws_lambda_function.processor.arn
  alerts_arn                                 = aws_sns_topic.alerts.arn
  perm_aws_s3_bucket_source_to_processor_id  = aws_lambda_permission.perm_aws_s3_bucket_source_to_processor.id
  aws_sns_topic_policy_alerts_st_modlab_a_id = aws_sns_topic_policy.aws_sns_topic_policy_alerts_st_modlab-a.id
}
