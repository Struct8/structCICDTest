locals {
  aws_codebuild_project_codebuild_lab_integration_arn  = "arn:aws:codebuild:us-west-2:952133486861:project/codebuild-lab-integration"
  aws_codebuild_project_codebuild_lab_integration_name = "codebuild-lab-integration"
}

data "aws_codestarconnections_connection" "codebuild-lab-github" {
  name = "codebuild-lab-github"
}
