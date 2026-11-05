resource "aws_ecr_repository" "codebuild-lab-orders" {
  name                 = "codebuild-lab-orders"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  tags = {
    Name           = "codebuild-lab-orders"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}
