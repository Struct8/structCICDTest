resource "aws_cloudwatch_log_group" "struct8-engine-logs" {
  name              = "/aws/codebuild/struct8-engine"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  tags = {
    Name           = "struct8-engine-logs"
    State          = "gitops-engine-codebuild-runner"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_metric_alarm" "struct8-engine-failed-builds" {
  alarm_name          = "struct8-engine-failed-builds"
  metric_name         = "FailedBuilds"
  alarm_actions       = [aws_sns_topic.struct8-engine-alerts.arn]
  alarm_description   = "A build of the CodeBuild project that runs the GitOps engine failed. Check the build logs and the run in GitHub Actions."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/CodeBuild"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"
  dimensions = {
    ProjectName = aws_codebuild_project.gitopslab-engine.name
  }
  tags = {
    Name           = "struct8-engine-failed-builds"
    State          = "gitops-engine-codebuild-runner"
    Struct8Creator = "rmay struct"
  }
}
