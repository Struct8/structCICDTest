resource "aws_cloudwatch_event_rule" "codebuild-lab-nightly" {
  name                = "codebuild-lab-nightly"
  description         = "Runs the integration tests every day at 00:00 UTC."
  schedule_expression = "cron(0 0 * * ? *)"
  state               = "ENABLED"
  tags = {
    Name           = "codebuild-lab-nightly"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "nightly-integration" {
  arn      = aws_codebuild_project.codebuild-lab-integration.arn
  role_arn = aws_iam_role.role_eventbridge_codebuild-lab-nightly.arn
  rule     = aws_cloudwatch_event_rule.codebuild-lab-nightly.name
}
