resource "aws_iam_instance_profile" "demo-pgweb_profile" {
  name = "demo-pgweb_profile"
  role = aws_iam_role.demo-pgweb_role.name
  tags = {
    Name           = "demo-pgweb_profile"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "db_proxy_demo-postgres-proxy_st_demo-postgres-state_doc" {
  statement {
    sid       = "ReadDatabaseCredentials"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)]
  }
}

resource "aws_iam_policy" "db_proxy_demo-postgres-proxy_st_demo-postgres-state" {
  name        = "db_proxy_demo-postgres-proxy_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-proxy"
  policy      = data.aws_iam_policy_document.db_proxy_demo-postgres-proxy_st_demo-postgres-state_doc.json
}

data "aws_iam_policy_document" "instance_demo-pgweb_st_demo-postgres-state_doc" {
  statement {
    sid       = "AllowRDSSecretAccessdemopostgres"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.demo-postgres.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "instance_demo-pgweb_st_demo-postgres-state" {
  name        = "instance_demo-pgweb_st_demo-postgres-state"
  description = "Access Policy for demo-pgweb"
  policy      = data.aws_iam_policy_document.instance_demo-pgweb_st_demo-postgres-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-postgres-api_st_demo-postgres-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-postgres-api-logs.arn}:*"]
  }
  statement {
    sid       = "ReadDatabaseCredentials"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [one(aws_db_instance.demo-postgres.master_user_secret[*].secret_arn)]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-postgres-api_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-api_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-api"
  policy      = data.aws_iam_policy_document.lambda_function_demo-postgres-api_st_demo-postgres-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-postgres-direct_st_demo-postgres-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-postgres-direct-logs.arn}:*"]
  }
  statement {
    sid       = "AllowRDSSecretAccessdemopostgres"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.demo-postgres.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-postgres-direct_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-direct_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-direct"
  policy      = data.aws_iam_policy_document.lambda_function_demo-postgres-direct_st_demo-postgres-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-postgres-iam_st_demo-postgres-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-postgres-iam-logs.arn}:*"]
  }
  statement {
    sid       = "AllowRDSSecretAccessdemopostgres"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_db_instance.demo-postgres.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
  statement {
    sid       = "RdsIamConnect"
    effect    = "Allow"
    actions   = ["rds-db:connect"]
    resources = ["arn:aws:rds-db:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.demo-postgres.resource_id}/lambda_iam"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-postgres-iam_st_demo-postgres-state" {
  name        = "lambda_function_demo-postgres-iam_st_demo-postgres-state"
  description = "Access Policy for demo-postgres-iam"
  policy      = data.aws_iam_policy_document.lambda_function_demo-postgres-iam_st_demo-postgres-state_doc.json
}

data "aws_iam_policy_document" "Debug_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["LWOdB7cr7ocaaK7CXIwEL"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-LWOdB7cr7ocaaK7CXIwEL"]
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
      values   = ["LWOdB7cr7ocaaK7CXIwEL"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "Debug_debug_trust" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type        = "AWS"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Struct8Debug-Debug" {
  name                 = "Struct8Debug-LWOdB7cr7ocaaK7CXIwEL"
  assume_role_policy   = data.aws_iam_policy_document.Debug_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "demo-pgweb_role" {
  name = "demo-pgweb_role"
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
    Name           = "demo-pgweb_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-api_role" {
  name = "demo-postgres-api_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-api_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-direct_role" {
  name = "demo-postgres-direct_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-direct_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-postgres-iam_role" {
  name = "demo-postgres-iam_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-postgres-iam_role"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_monitoring_demo-postgres" {
  name = "role_monitoring_demo-postgres"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      }
    }
  ]
})
  tags = {
    Name           = "role_monitoring_demo-postgres"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_rds_proxy_demo-postgres-proxy" {
  name = "role_rds_proxy_demo-postgres-proxy"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_rds_proxy_demo-postgres-proxy"
    State          = "demo-postgres-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-Debug_policy" {
  name   = "Struct8Debug-LWOdB7cr7ocaaK7CXIwEL-policy"
  policy = data.aws_iam_policy_document.Debug_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-Debug.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "db_proxy_demo-postgres-proxy_st_demo-postgres-state_attach" {
  policy_arn = aws_iam_policy.db_proxy_demo-postgres-proxy_st_demo-postgres-state.arn
  role       = aws_iam_role.role_rds_proxy_demo-postgres-proxy.name
}

resource "aws_iam_role_policy_attachment" "instance_demo-pgweb_st_demo-postgres-state_attach" {
  policy_arn = aws_iam_policy.instance_demo-pgweb_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-api_st_demo-postgres-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-api_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-api_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-direct_st_demo-postgres-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-direct_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-direct_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-postgres-iam_st_demo-postgres-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-postgres-iam_st_demo-postgres-state.arn
  role       = aws_iam_role.demo-postgres-iam_role.name
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonRDSEnhancedMonitoringRole_to_demo-postgres_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.role_monitoring_demo-postgres.name
}
