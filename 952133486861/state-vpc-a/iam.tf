resource "aws_iam_instance_profile" "nat-a_profile" {
  name = "nat-a_profile"
  role = aws_iam_role.nat-a_role.name
  tags = {
    Name           = "nat-a_profile"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "traffic-gen-private_profile" {
  name = "traffic-gen-private_profile"
  role = aws_iam_role.traffic-gen-private_role.name
  tags = {
    Name           = "traffic-gen-private_profile"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "traffic-gen-public_profile" {
  name = "traffic-gen-public_profile"
  role = aws_iam_role.traffic-gen-public_role.name
  tags = {
    Name           = "traffic-gen-public_profile"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "instance_traffic-gen-private_st_state-vpc-a_doc" {
  statement {
    sid       = "AllowDynamoDBCRUD"
    effect    = "Allow"
    actions   = ["dynamodb:BatchGetItem", "dynamodb:DeleteItem", "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.traffic-table-a.arn, "${aws_dynamodb_table.traffic-table-a.arn}/*"]
  }
  statement {
    sid       = "AllowBucketLevelActions"
    effect    = "Allow"
    actions   = ["s3:GetBucketLocation", "s3:ListBucket"]
    resources = [aws_s3_bucket.traffic-bucket.arn]
  }
  statement {
    sid       = "AllowObjectCRUD"
    effect    = "Allow"
    actions   = ["s3:DeleteObject", "s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.traffic-bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "instance_traffic-gen-private_st_state-vpc-a" {
  name        = "instance_traffic-gen-private_st_state-vpc-a"
  description = "Access Policy for traffic-gen-private"
  policy      = data.aws_iam_policy_document.instance_traffic-gen-private_st_state-vpc-a_doc.json
}

data "aws_iam_policy_document" "debug-gen-private_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["FX2YywXH644G8HUw23NLU"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-FX2YywXH644G8HUw23NLU"]
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
      values   = ["FX2YywXH644G8HUw23NLU"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "debug-gen-private_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "debug-gen-public_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["Sl9JhZ0nMqByjOi8dVpJa"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-Sl9JhZ0nMqByjOi8dVpJa"]
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
      values   = ["Sl9JhZ0nMqByjOi8dVpJa"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "debug-gen-public_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Struct8Debug-debug-gen-private" {
  name                 = "Struct8Debug-FX2YywXH644G8HUw23NLU"
  assume_role_policy   = data.aws_iam_policy_document.debug-gen-private_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "Struct8Debug-debug-gen-public" {
  name                 = "Struct8Debug-Sl9JhZ0nMqByjOi8dVpJa"
  assume_role_policy   = data.aws_iam_policy_document.debug-gen-public_debug_trust.json
  max_session_duration = 3600
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
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "traffic-gen-private_role" {
  name = "traffic-gen-private_role"
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
    Name           = "traffic-gen-private_role"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "traffic-gen-public_role" {
  name = "traffic-gen-public_role"
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
    Name           = "traffic-gen-public_role"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-debug-gen-private_policy" {
  name   = "Struct8Debug-FX2YywXH644G8HUw23NLU-policy"
  policy = data.aws_iam_policy_document.debug-gen-private_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-debug-gen-private.id
}

resource "aws_iam_role_policy" "Struct8Debug-debug-gen-public_policy" {
  name   = "Struct8Debug-Sl9JhZ0nMqByjOi8dVpJa-policy"
  policy = data.aws_iam_policy_document.debug-gen-public_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-debug-gen-public.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_traffic-gen-private_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.traffic-gen-private_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_traffic-gen-public_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.traffic-gen-public_role.name
}

resource "aws_iam_role_policy_attachment" "instance_traffic-gen-private_st_state-vpc-a_attach" {
  policy_arn = aws_iam_policy.instance_traffic-gen-private_st_state-vpc-a.arn
  role       = aws_iam_role.traffic-gen-private_role.name
}
