resource "aws_iam_instance_profile" "nat-windows-secure_profile" {
  name = "nat-windows-secure_profile"
  role = aws_iam_role.nat-windows-secure_role.name
  tags = {
    Name           = "nat-windows-secure_profile"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "windows-secure_profile" {
  name = "windows-secure_profile"
  role = aws_iam_role.windows-secure_role.name
  tags = {
    Name           = "windows-secure_profile"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "nat-windows-secure_role" {
  name = "nat-windows-secure_role"
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
    Name           = "nat-windows-secure_role"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "windows-secure_role" {
  name = "windows-secure_role"
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
    Name           = "windows-secure_role"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_windows-secure_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.windows-secure_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_windows-secure_profile_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.windows-secure_role.name
}
