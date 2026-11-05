resource "aws_iam_instance_profile" "windows-basic_profile" {
  name = "windows-basic_profile"
  role = aws_iam_role.windows-basic_role.name
  tags = {
    Name           = "windows-basic_profile"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "windows-basic_role" {
  name = "windows-basic_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "windows-basic_role"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}
