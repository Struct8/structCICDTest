resource "aws_cloudwatch_event_rule" "every-1-minute" {
  name                = "every-1-minute"
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
  tags = {
    Name           = "every-1-minute"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  target_id  = "terraform-xlSz57HKZe7cggI4iEcnHuzze0"
  arn        = aws_lambda_function.demo-postgres-direct.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-direct]
}

resource "aws_cloudwatch_event_target" "Target1" {
  target_id  = "terraform-esy2tEx2JBS5IjgcqcadTC1kyx"
  arn        = aws_lambda_function.demo-postgres-api.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-api]
}

resource "aws_cloudwatch_event_target" "Target2" {
  target_id  = "terraform-UgFi698Te6diAzlIMUkmKwKShE"
  arn        = aws_lambda_function.demo-postgres-iam.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-postgres-iam]
}
