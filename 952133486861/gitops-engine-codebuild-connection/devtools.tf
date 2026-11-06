resource "aws_codeconnections_connection" "gitopslab-engine-github" {
  name          = "gitopslab-engine-github"
  provider_type = "GitHub"
  tags = {
    Name           = "gitopslab-engine-github"
    State          = "gitops-engine-codebuild-connection"
    Struct8Creator = "rmay struct"
  }
}
