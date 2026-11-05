resource "aws_codeconnections_connection" "codebuild-lab-github" {
  name          = "codebuild-lab-github"
  provider_type = "GitHub"
  tags = {
    Name           = "codebuild-lab-github"
    State          = "codebuild-lab-connection"
    Struct8Creator = "rmay struct"
  }
}
