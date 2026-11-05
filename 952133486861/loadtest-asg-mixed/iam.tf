resource "aws_iam_instance_profile" "hub-asg-mixed_profile" {
  name = "hub-asg-mixed_profile"
  role = aws_iam_role.hub-asg-mixed_role.name
  tags = {
    Name           = "hub-asg-mixed_profile"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "k6-load-generator_profile" {
  name = "k6-load-generator_profile"
  role = aws_iam_role.k6-load-generator_role.name
  tags = {
    Name           = "k6-load-generator_profile"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "nat-a_profile" {
  name = "nat-a_profile"
  role = aws_iam_role.nat-a_role.name
  tags = {
    Name           = "nat-a_profile"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "k6-debug_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["0WMToJ4cZSqnBZhOjNzSl"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-0WMToJ4cZSqnBZhOjNzSl"]
  }
  statement {
    sid       = "ReadOwnResults"
    effect    = "Allow"
    actions   = ["ssm:GetCommandInvocation", "ssm:DescribeInstanceInformation"]
    resources = ["*"]
  }
  statement {
    sid       = "CancelOnTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:CancelCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["0WMToJ4cZSqnBZhOjNzSl"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "k6-debug_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Struct8Debug-k6-debug" {
  name                 = "Struct8Debug-0WMToJ4cZSqnBZhOjNzSl"
  assume_role_policy   = data.aws_iam_policy_document.k6-debug_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "hub-asg-mixed_role" {
  name = "hub-asg-mixed_role"
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
    Name           = "hub-asg-mixed_role"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k6-load-generator_role" {
  name = "k6-load-generator_role"
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
    Name           = "k6-load-generator_role"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "nat-a_role" {
  name = "nat-a_role"
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
    Name           = "nat-a_role"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-k6-debug_policy" {
  name   = "Struct8Debug-0WMToJ4cZSqnBZhOjNzSl-policy"
  policy = data.aws_iam_policy_document.k6-debug_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-k6-debug.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_k6-load-generator_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.k6-load-generator_role.name
}
