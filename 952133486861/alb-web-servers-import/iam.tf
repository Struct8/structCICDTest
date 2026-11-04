resource "aws_iam_instance_profile" "nat-instance_profile" {
  name = "nat-instance_profile"
  path = "/"
  role = aws_iam_role.nat-instance_role.name
  tags = {
    Name           = "nat-instance_profile"
    State          = "alb-web-servers-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "web-server-asg_profile" {
  name = "web-server-asg_profile"
  path = "/"
  role = aws_iam_role.web-server-asg_role.name
  tags = {
    Name           = "web-server-asg_profile"
    State          = "alb-web-servers-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "nat-instance_role" {
  name                  = "nat-instance_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "nat-instance_role"
    State          = "alb-web-servers-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "web-server-asg_role" {
  name                  = "web-server-asg_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "web-server-asg_role"
    State          = "alb-web-servers-import"
    Struct8Creator = "rmay struct"
  }
}
