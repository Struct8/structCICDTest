resource "aws_ecr_repository" "kuma-image" {
  name                 = "kuma-image"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name           = "kuma-image"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_ecr_repository" "wp-image" {
  name                 = "wp-image"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name           = "wp-image"
    State          = "beanstalk-wordpress"
    Struct8Creator = "rmay struct"
  }
}
