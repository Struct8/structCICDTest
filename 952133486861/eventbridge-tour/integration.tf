resource "aws_sqs_queue" "fanout-queue" {
  name                              = "fanout-queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags = {
    Name           = "fanout-queue"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sqs_queue_policy_fanout-queue_st_eventbridge-tour_doc" {
  statement {
    sid    = "AllowEventBridgeToSendMessageToSQS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.fanout-queue.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sqs_queue_policy" "aws_sqs_queue_policy_fanout-queue_st_eventbridge-tour" {
  policy    = data.aws_iam_policy_document.aws_sqs_queue_policy_fanout-queue_st_eventbridge-tour_doc.json
  queue_url = aws_sqs_queue.fanout-queue.id
}

resource "aws_sns_topic" "fanout-topic" {
  name           = "fanout-topic"
  tracing_config = "Active"
  tags = {
    Name           = "fanout-topic"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_xray_resource_policy.aws_xray_resource_policy_st_eventbridge-tour_d5b4d0b8f5]
}

data "aws_iam_policy_document" "aws_sns_topic_policy_fanout-topic_st_eventbridge-tour_doc" {
  statement {
    sid    = "AllowEventBridgeToPublishToSNS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.fanout-topic.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_fanout-topic_st_eventbridge-tour" {
  arn    = aws_sns_topic.fanout-topic.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_fanout-topic_st_eventbridge-tour_doc.json
}

resource "aws_sns_topic_subscription" "Subscription2" {
  endpoint   = aws_lambda_function.fanout-consumer-a.arn
  protocol   = "lambda"
  topic_arn  = aws_sns_topic.fanout-topic.arn
  depends_on = [aws_lambda_permission.perm_aws_sns_topic_fanout-topic_to_fanout-consumer-a]
}

resource "aws_cloudwatch_event_archive" "tour-archive" {
  name             = "eventbridge-tour-archive"
  description      = "SECTION 3 - Archive on the custom bus: retains events for 7 days so they can be replayed later. Its event_source_arn references the tour-bus."
  event_source_arn = aws_cloudwatch_event_bus.tour-bus.arn
  retention_days   = 7
}

resource "aws_cloudwatch_event_bus" "tour-bus" {
  name        = "tour-bus"
  description = "Custom event bus. Receives events ONLY from code that calls PutEvents (schedule-target-fn publishes here); AWS-native sources like S3 never reach a custom bus, they go to the default bus."
  tags = {
    Name           = "tour-bus"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_rule" "rule-event-pattern" {
  event_bus_name = aws_cloudwatch_event_bus.tour-bus.name
  name           = "rule-event-pattern"
  description    = "SECTION 1 - Event pattern trigger: matches a custom application event"
  event_pattern  = "{\"source\":[\"struct8.hub\"],\"detail-type\":[\"Hub Message\"]}"
  state          = "ENABLED"
  tags = {
    Name           = "rule-event-pattern"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_fanout-queue_st_eventbridge-tour]
}

resource "aws_cloudwatch_event_rule" "rule-fanout" {
  name        = "rule-fanout"
  description = "SECTION 2 - Fan-out: ONE event matched here is delivered to multiple targets (2 Lambdas + SQS + SNS)"
  event_pattern = <<EOF
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "Object Created"
  ],
  "detail": {
    "bucket": {
      "name": [
        "${aws_s3_bucket.uploads-bucket.bucket}"
      ]
    }
  }
}
  EOF
  state = "ENABLED"
  tags = {
    Name           = "rule-fanout"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sqs_queue_policy.aws_sqs_queue_policy_fanout-queue_st_eventbridge-tour, aws_sns_topic_policy.aws_sns_topic_policy_fanout-topic_st_eventbridge-tour]
}

resource "aws_cloudwatch_event_rule" "rule-schedule-1min" {
  name                = "rule-schedule-1min"
  description         = "SECTION 1 - Schedule trigger: runs every 1 minute (rate expression)"
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
  tags = {
    Name           = "rule-schedule-1min"
    State          = "eventbridge-tour"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "tgt-eventpattern-queue" {
  event_bus_name = aws_cloudwatch_event_bus.tour-bus.name
  arn            = aws_sqs_queue.fanout-queue.arn
  input          = "{\"trigger\": \"custom-app-event\", \"note\": \"constant payload replaces the matched event\"}"
  rule           = aws_cloudwatch_event_rule.rule-event-pattern.name
}

resource "aws_cloudwatch_event_target" "tgt-fanout-a" {
  arn        = aws_lambda_function.fanout-consumer-a.arn
  rule       = aws_cloudwatch_event_rule.rule-fanout.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-a]
}

resource "aws_cloudwatch_event_target" "tgt-fanout-b" {
  arn  = aws_lambda_function.fanout-consumer-b.arn
  rule = aws_cloudwatch_event_rule.rule-fanout.name
  input_transformer {
    input_template = "{\"message\": \"New object <key> landed in <bucket>\"}"
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
    }
  }
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_rule-fanout_to_fanout-consumer-b]
}

resource "aws_cloudwatch_event_target" "tgt-fanout-queue" {
  arn  = aws_sqs_queue.fanout-queue.arn
  rule = aws_cloudwatch_event_rule.rule-fanout.name
}

resource "aws_cloudwatch_event_target" "tgt-fanout-topic" {
  arn  = aws_sns_topic.fanout-topic.arn
  rule = aws_cloudwatch_event_rule.rule-fanout.name
}

resource "aws_cloudwatch_event_target" "tgt-schedule-fn" {
  arn        = aws_lambda_function.schedule-target-fn.arn
  rule       = aws_cloudwatch_event_rule.rule-schedule-1min.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_rule-schedule-1min_to_schedule-target-fn]
}

resource "aws_scheduler_schedule" "sched-flexible" {
  name                = "sched-flexible"
  description         = "SECTION 1 - EventBridge Scheduler (the newer service): flexible delivery window + timezone"
  schedule_expression = "rate(1 minute)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_sqs_queue.fanout-queue.arn
    role_arn = aws_iam_role.sched-flexible_role.arn
  }
  depends_on = [aws_iam_role_policy_attachment.scheduler_schedule_sched-flexible_st_eventbridge-tour_attach]
}
