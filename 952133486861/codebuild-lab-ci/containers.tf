resource "aws_ecr_repository" "codebuild-lab-orders" {
  name                 = "codebuild-lab-orders"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name           = "codebuild-lab-orders"
    State          = "codebuild-lab-ci"
    Struct8Creator = "rmay struct"
  }
}
