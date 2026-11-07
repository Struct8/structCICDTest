resource "aws_sns_topic" "modlab-c-topico" {
  name = "modlab-c-topico"
  tags = {
    Name           = "modlab-c-topico"
    State          = "modlab-c"
    Struct8Creator = "rmay struct"
  }
  depends_on = [module.mensageria.aws_sqs_queue_policy_modlab_c_fila_st_modlab_c_whole]
}

resource "aws_sns_topic_subscription" "Subscription" {
  endpoint  = module.mensageria.modlab_c_fila_arn
  protocol  = "sqs"
  topic_arn = aws_sns_topic.modlab-c-topico.arn
}
