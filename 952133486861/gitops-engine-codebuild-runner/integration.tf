resource "aws_sns_topic" "struct8-engine-alerts" {
  name = "struct8-engine-alerts"
  tags = {
    Name           = "struct8-engine-alerts"
    State          = "gitops-engine-codebuild-runner"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_sns_topic_subscription" "struct8-engine-alerts-email" {
  endpoint  = "lab@acme.example"
  protocol  = "email"
  topic_arn = aws_sns_topic.struct8-engine-alerts.arn
}
