resource "aws_cloudwatch_log_group" "codebuild-lab-pr-check-logs" {
  name              = "/aws/codebuild/codebuild-lab-pr-check"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "codebuild-lab-pr-check-logs"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "codebuild-lab-release-logs" {
  name              = "/aws/codebuild/codebuild-lab-release"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "codebuild-lab-release-logs"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "codebuild-lab-runner-logs" {
  name              = "/aws/codebuild/codebuild-lab-runner"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "codebuild-lab-runner-logs"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_metric_alarm" "codebuild-lab-failed-builds" {
  alarm_name          = "codebuild-lab-failed-builds"
  alarm_actions       = [aws_sns_topic.codebuild-lab-notifications.arn]
  alarm_description   = "A pull request check or a release build failed."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  treat_missing_data  = "notBreaching"
  metric_query {
    id          = "e1"
    expression  = "SUM(METRICS())"
    return_data = true
  }
  metric_query {
    id = "m1"
    metric {
      metric_name = "FailedBuilds"
      namespace   = "AWS/CodeBuild"
      period      = 300
      stat        = "Sum"
      dimensions = {
        ProjectName = aws_codebuild_project.codebuild-lab-pr-check.name
      }
    }
  }
  metric_query {
    id = "m2"
    metric {
      metric_name = "FailedBuilds"
      namespace   = "AWS/CodeBuild"
      period      = 300
      stat        = "Sum"
      dimensions = {
        ProjectName = aws_codebuild_project.codebuild-lab-release.name
      }
    }
  }
  tags = {
    Name           = "codebuild-lab-failed-builds"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_sns_topic_policy.aws_sns_topic_policy_codebuild-lab-notifications_st_codebuild-lab-ci]
}
