data "aws_iam_role" "role_eventbridge_codebuild-lab-release-succeeded" {
  name = "role_eventbridge_codebuild-lab-release-succeeded"
}

data "aws_codestarconnections_connection" "codebuild-lab-github" {
  name = "codebuild-lab-github"
}
