resource "aws_sns_topic" "codebuild-lab-notifications" {
  name = "codebuild-lab-notifications"
  tags = {
    Name           = "codebuild-lab-notifications"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "aws_sns_topic_policy_codebuild-lab-notifications_st_codebuild-lab-ci_doc" {
  statement {
    sid    = "AllowCloudWatchAlarmsToPublish"
    effect = "Allow"
    principals {
      identifiers = ["cloudwatch.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.codebuild-lab-notifications.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
  statement {
    sid    = "AllowEventBridgeToPublishToSNS"
    effect = "Allow"
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.codebuild-lab-notifications.arn]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.current.account_id]
      variable = "AWS:SourceAccount"
    }
  }
}

resource "aws_sns_topic_policy" "aws_sns_topic_policy_codebuild-lab-notifications_st_codebuild-lab-ci" {
  arn    = aws_sns_topic.codebuild-lab-notifications.arn
  policy = data.aws_iam_policy_document.aws_sns_topic_policy_codebuild-lab-notifications_st_codebuild-lab-ci_doc.json
}

resource "aws_sns_topic_subscription" "codebuild-lab-email" {
  endpoint  = "lab@acme.example"
  protocol  = "email"
  topic_arn = aws_sns_topic.codebuild-lab-notifications.arn
}

resource "aws_cloudwatch_event_rule" "codebuild-lab-build-finished" {
  name          = "codebuild-lab-build-finished"
  description   = "Every finished build of the lab projects, sent to the notifications topic."
  event_pattern = "{\"detail\":{\"build-status\":[\"SUCCEEDED\",\"FAILED\",\"STOPPED\"],\"project-name\":[\"codebuild-lab-pr-check\",\"codebuild-lab-release\",\"codebuild-lab-runner\",\"codebuild-lab-integration\"]},\"detail-type\":[\"CodeBuild Build State Change\"],\"source\":[\"aws.codebuild\"]}"
  state         = "ENABLED"
  tags = {
    Name           = "codebuild-lab-build-finished"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_codebuild-lab-notifications_st_codebuild-lab-ci]
}

resource "aws_cloudwatch_event_rule" "codebuild-lab-release-succeeded" {
  name          = "codebuild-lab-release-succeeded"
  description   = "A release build that succeeded starts the integration tests."
  event_pattern = "{\"detail\":{\"build-status\":[\"SUCCEEDED\"],\"project-name\":[\"codebuild-lab-release\"]},\"detail-type\":[\"CodeBuild Build State Change\"],\"source\":[\"aws.codebuild\"]}"
  state         = "ENABLED"
  tags = {
    Name           = "codebuild-lab-release-succeeded"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "notify-email" {
  target_id = "terraform-skTYmYql1mRLpLj3rWFqrUMh5H"
  arn       = aws_sns_topic.codebuild-lab-notifications.arn
  rule      = aws_cloudwatch_event_rule.codebuild-lab-build-finished.name
  input_transformer {
    input_template = "\"CodeBuild <project>: <status> at <time>. Build <build>\""
    input_paths = {
      build   = "$.detail.build-id"
      project = "$.detail.project-name"
      status  = "$.detail.build-status"
      time    = "$.time"
    }
  }
}

resource "aws_cloudwatch_event_target" "release-integration" {
  target_id = "terraform-F2Jvm39DZIZ81zhATfWnYrYELh"
  arn       = "arn:aws:codebuild:us-west-2:952133486861:project/codebuild-lab-integration"
  rule      = aws_cloudwatch_event_rule.codebuild-lab-release-succeeded.name
}
