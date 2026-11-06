resource "aws_iam_instance_profile" "nat-b_profile" {
  name = "nat-b_profile"
  role = aws_iam_role.nat-b_role.name
  tags = {
    Name           = "nat-b_profile"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "traffic-gen-asg_profile" {
  name = "traffic-gen-asg_profile"
  role = aws_iam_role.traffic-gen-asg_role.name
  tags = {
    Name           = "traffic-gen-asg_profile"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "autoscaling_group_traffic-gen-asg_st_state-vpc-b_doc" {
  statement {
    sid       = "AllowDynamoDBCRUD"
    effect    = "Allow"
    actions   = ["dynamodb:BatchGetItem", "dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.traffic-table-b.arn, "${aws_dynamodb_table.traffic-table-b.arn}/*"]
  }
}

resource "aws_iam_policy" "autoscaling_group_traffic-gen-asg_st_state-vpc-b" {
  name        = "autoscaling_group_traffic-gen-asg_st_state-vpc-b"
  description = "Access Policy for traffic-gen-asg"
  policy      = data.aws_iam_policy_document.autoscaling_group_traffic-gen-asg_st_state-vpc-b_doc.json
}

data "aws_iam_policy_document" "debug-gen-asg_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["dSoyaOy7hbpHYVsbxeFUF"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-dSoyaOy7hbpHYVsbxeFUF"]
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
      values   = ["dSoyaOy7hbpHYVsbxeFUF"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "debug-gen-asg_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Struct8Debug-debug-gen-asg" {
  name                 = "Struct8Debug-dSoyaOy7hbpHYVsbxeFUF"
  assume_role_policy   = data.aws_iam_policy_document.debug-gen-asg_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "nat-b_role" {
  name = "nat-b_role"
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
    Name           = "nat-b_role"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "traffic-gen-asg_role" {
  name = "traffic-gen-asg_role"
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
    Name           = "traffic-gen-asg_role"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-debug-gen-asg_policy" {
  name   = "Struct8Debug-dSoyaOy7hbpHYVsbxeFUF-policy"
  policy = data.aws_iam_policy_document.debug-gen-asg_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-debug-gen-asg.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_traffic-gen-asg_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.traffic-gen-asg_role.name
}

resource "aws_iam_role_policy_attachment" "autoscaling_group_traffic-gen-asg_st_state-vpc-b_attach" {
  policy_arn = aws_iam_policy.autoscaling_group_traffic-gen-asg_st_state-vpc-b.arn
  role       = aws_iam_role.traffic-gen-asg_role.name
}
