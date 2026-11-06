resource "aws_cloudwatch_log_group" "codebuild-lab-integration-logs" {
  name              = "/aws/codebuild/codebuild-lab-integration"
  log_group_class   = "STANDARD"
  retention_in_days = 14
  skip_destroy      = false
  tags = {
    Name           = "codebuild-lab-integration-logs"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}
