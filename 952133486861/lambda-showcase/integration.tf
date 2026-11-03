resource "aws_sns_topic" "alerts" {
  name = "alerts"
  tags = {
    Name           = "alerts"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_rule" "every-5-min" {
  name                = "every-5-min"
  description         = "EventBridge schedule that fires every five minutes, enabled. It invokes the function asynchronously and passes the scheduled instant in the event."
  schedule_expression = "rate(5 minutes)"
  state               = "ENABLED"
  tags = {
    Name           = "every-5-min"
    State          = "lambda-showcase"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  target_id  = "terraform-PamdYI57sma88bIrbAfZlKqSfh"
  arn        = aws_lambda_function.worker.arn
  rule       = aws_cloudwatch_event_rule.every-5-min.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-5-min_to_worker]
}
