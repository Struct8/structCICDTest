terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/demo-aurora-state/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "demo-pgweb_profile" {
  name = "demo-pgweb_profile"
  path = "/"
  role = aws_iam_role.demo-pgweb_role.name
  tags = {
    Name           = "demo-pgweb_profile"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_iam_policy_document" "db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state_doc" {
  statement {
    sid       = "ReadDatabaseCredentials"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"]
  }
}

resource "aws_iam_policy" "db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state" {
  name        = "db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state"
  description = "Access Policy for demo-aurora-rds-proxy"
  policy      = data.aws_iam_policy_document.db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "instance_demo-pgweb_st_demo-aurora-state_doc" {
  statement {
    sid       = "AllowRDSDataApidemoaurora"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.demo-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessdemoaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.demo-aurora.master_user_secret[0].secret_arn]
  }
}

resource "aws_iam_policy" "instance_demo-pgweb_st_demo-aurora-state" {
  name        = "instance_demo-pgweb_st_demo-aurora-state"
  description = "Access Policy for demo-pgweb"
  policy      = data.aws_iam_policy_document.instance_demo-pgweb_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-aurora-dataapi_st_demo-aurora-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-aurora-dataapi-logs.arn}:*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-aurora-dataapi_st_demo-aurora-state" {
  name        = "lambda_function_demo-aurora-dataapi_st_demo-aurora-state"
  description = "Access Policy for demo-aurora-dataapi"
  policy      = data.aws_iam_policy_document.lambda_function_demo-aurora-dataapi_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-aurora-direct_st_demo-aurora-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-aurora-direct-logs.arn}:*"]
  }
  statement {
    sid       = "AllowRDSDataApidemoaurora"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.demo-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessdemoaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.demo-aurora.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-aurora-direct_st_demo-aurora-state" {
  name        = "lambda_function_demo-aurora-direct_st_demo-aurora-state"
  description = "Access Policy for demo-aurora-direct"
  policy      = data.aws_iam_policy_document.lambda_function_demo-aurora-direct_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-aurora-iam_st_demo-aurora-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-aurora-iam-logs.arn}:*"]
  }
  statement {
    sid       = "AllowRDSDataApidemoaurora"
    effect    = "Allow"
    actions   = ["rds-data:BatchExecuteStatement", "rds-data:BeginTransaction", "rds-data:CommitTransaction", "rds-data:ExecuteStatement", "rds-data:RollbackTransaction"]
    resources = [aws_rds_cluster.demo-aurora.arn]
  }
  statement {
    sid       = "AllowRDSSecretAccessdemoaurora"
    effect    = "Allow"
    actions   = ["secretsmanager:DescribeSecret", "secretsmanager:GetSecretValue"]
    resources = [aws_rds_cluster.demo-aurora.master_user_secret[0].secret_arn]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-aurora-iam_st_demo-aurora-state" {
  name        = "lambda_function_demo-aurora-iam_st_demo-aurora-state"
  description = "Access Policy for demo-aurora-iam"
  policy      = data.aws_iam_policy_document.lambda_function_demo-aurora-iam_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "lambda_function_demo-aurora-proxy_st_demo-aurora-state_doc" {
  statement {
    sid       = "AllowWriteLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.demo-aurora-proxy-logs.arn}:*"]
  }
  statement {
    sid       = "AllowAllResources"
    effect    = "Allow"
    actions   = ["ec2:AssignPrivateIpAddresses", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:UnassignPrivateIpAddresses"]
    resources = ["*"]
  }
  statement {
    sid       = "ReadDatabaseCredentials"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"]
  }
}

resource "aws_iam_policy" "lambda_function_demo-aurora-proxy_st_demo-aurora-state" {
  name        = "lambda_function_demo-aurora-proxy_st_demo-aurora-state"
  description = "Access Policy for demo-aurora-proxy"
  policy      = data.aws_iam_policy_document.lambda_function_demo-aurora-proxy_st_demo-aurora-state_doc.json
}

data "aws_iam_policy_document" "Debug_debug_permissions" {
  statement {
    sid       = "SendToTaggedInstancesOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      values   = ["PSH0iot7vZkT3iq-O7LSR"]
      variable = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid       = "PinnedDocumentOnly"
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-PSH0iot7vZkT3iq-O7LSR"]
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
      values   = ["PSH0iot7vZkT3iq-O7LSR"]
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
  name                 = "Struct8Debug-PSH0iot7vZkT3iq-O7LSR"
  assume_role_policy   = data.aws_iam_policy_document.Debug_debug_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role" "demo-aurora-dataapi_role" {
  name                  = "demo-aurora-dataapi_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-aurora-dataapi_role"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-aurora-direct_role" {
  name                  = "demo-aurora-direct_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-aurora-direct_role"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-aurora-iam_role" {
  name                  = "demo-aurora-iam_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-aurora-iam_role"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-aurora-proxy_role" {
  name                  = "demo-aurora-proxy_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-aurora-proxy_role"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "demo-pgweb_role" {
  name                  = "demo-pgweb_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "demo-pgweb_role"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_rds_proxy_demo-aurora-rds-proxy" {
  name                  = "role_rds_proxy_demo-aurora-rds-proxy"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"rds.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "role_rds_proxy_demo-aurora-rds-proxy"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy" "Struct8Debug-Debug_policy" {
  name   = "Struct8Debug-PSH0iot7vZkT3iq-O7LSR-policy"
  policy = data.aws_iam_policy_document.Debug_debug_permissions.json
  role   = aws_iam_role.Struct8Debug-Debug.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_demo-pgweb_profile_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state.arn
  role       = aws_iam_role.role_rds_proxy_demo-aurora-rds-proxy.name
}

resource "aws_iam_role_policy_attachment" "instance_demo-pgweb_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.instance_demo-pgweb_st_demo-aurora-state.arn
  role       = aws_iam_role.demo-pgweb_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-aurora-dataapi_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-aurora-dataapi_st_demo-aurora-state.arn
  role       = aws_iam_role.demo-aurora-dataapi_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-aurora-direct_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-aurora-direct_st_demo-aurora-state.arn
  role       = aws_iam_role.demo-aurora-direct_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-aurora-iam_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-aurora-iam_st_demo-aurora-state.arn
  role       = aws_iam_role.demo-aurora-iam_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_function_demo-aurora-proxy_st_demo-aurora-state_attach" {
  policy_arn = aws_iam_policy.lambda_function_demo-aurora-proxy_st_demo-aurora-state.arn
  role       = aws_iam_role.demo-aurora-proxy_role.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "aurora-serverless-access-patterns-lab" {
  cidr_block           = "10.8.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "aurora-serverless-access-patterns-lab"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "ep-cloudwatch_LOGS" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.logs"
  vpc_id              = aws_vpc.aurora-serverless-access-patterns-lab.id
  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-cloudwatch.id]
  subnet_ids          = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-cloudwatch"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-cloudwatch_LOGS"
  }
}

resource "aws_vpc_endpoint" "ep-secret-manager_SECRETSMANAGER" {
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_id              = aws_vpc.aurora-serverless-access-patterns-lab.id
  ip_address_type     = "ipv4"
  policy              = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}]}"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_vpce_ep-secret-manager.id]
  subnet_ids          = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  vpc_endpoint_type   = "Interface"
  tags = {
    Name           = "ep-secret-manager"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
    DifName        = "ep-secret-manager_SECRETSMANAGER"
  }
}

resource "aws_subnet" "demo-aurora-private-a" {
  vpc_id                              = aws_vpc.aurora-serverless-access-patterns-lab.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.8.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-aurora-private-a"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-aurora-private-b" {
  vpc_id                              = aws_vpc.aurora-serverless-access-patterns-lab.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.8.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-aurora-private-b"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-public-a" {
  vpc_id                              = aws_vpc.aurora-serverless-access-patterns-lab.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.8.10.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "demo-public-a"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.aurora-serverless-access-patterns-lab.id
  tags = {
    Name           = "demo-igw"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_demo-public-rt_to_demo-igw_ipv4" {
  gateway_id             = aws_internet_gateway.demo-igw.id
  route_table_id         = aws_route_table.demo-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "demo-public-rt" {
  vpc_id = aws_vpc.aurora-serverless-access-patterns-lab.id
  tags = {
    Name           = "demo-public-rt"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_demo_public_a_demo_public_rt" {
  route_table_id = aws_route_table.demo-public-rt.id
  subnet_id      = aws_subnet.demo-public-a.id
}

resource "aws_security_group" "db_proxy_demo-aurora-rds-proxy_group" {
  name                   = "db_proxy_demo-aurora-rds-proxy_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_proxy_demo-aurora-rds-proxy_group"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_demo-pgweb_group" {
  name                   = "instance_demo-pgweb_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "pgweb web UI"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_demo-pgweb_group"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "lambda_function_demo-aurora-direct_group" {
  name                   = "lambda_function_demo-aurora-direct_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
}

resource "aws_security_group" "lambda_function_demo-aurora-iam_group" {
  name                   = "lambda_function_demo-aurora-iam_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
}

resource "aws_security_group" "lambda_function_demo-aurora-proxy_group" {
  name                   = "lambda_function_demo-aurora-proxy_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "lambda_function_demo-aurora-proxy_group"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "rds_cluster_demo-aurora_group" {
  name                   = "rds_cluster_demo-aurora_group"
  vpc_id                 = aws_vpc.aurora-serverless-access-patterns-lab.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "rds_cluster_demo-aurora_group"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_ep-cloudwatch" {
  name        = "vpce-sg-ep-cloudwatch"
  vpc_id      = aws_vpc.aurora-serverless-access-patterns-lab.id
  description = "Auto-generated SG for ep-cloudwatch"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "ep-cloudwatch"
    DifName        = "sg_vpce_ep-cloudwatch"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "sg_vpce_ep-secret-manager" {
  name        = "vpce-sg-ep-secret-manager"
  vpc_id      = aws_vpc.aurora-serverless-access-patterns-lab.id
  description = "Auto-generated SG for ep-secret-manager"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "ep-secret-manager"
    DifName        = "sg_vpce_ep-secret-manager"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_db_proxy_demo_aurora_rds_proxy_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_proxy_demo-aurora-rds-proxy_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_db_proxy_demo_aurora_rds_proxy_group_to_rds_cluster_demo_aurora_group_tcp_5432" {
  security_group_id        = aws_security_group.rds_cluster_demo-aurora_group.id
  source_security_group_id = aws_security_group.db_proxy_demo-aurora-rds-proxy_group.id
  description              = "Allow from RDS Proxy demo-aurora-rds-proxy"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_demo-pgweb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_ingress_tcp_8081" {
  security_group_id = aws_security_group.instance_demo-pgweb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8081
  protocol          = "tcp"
  to_port           = 8081
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_demo_pgweb_group_to_rds_cluster_demo_aurora_group_tcp_5432" {
  security_group_id        = aws_security_group.rds_cluster_demo-aurora_group.id
  source_security_group_id = aws_security_group.instance_demo-pgweb_group.id
  description              = "Allow from instance_demo-pgweb_group (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_direct_group_egress_all_protocols" {
  security_group_id = aws_security_group.lambda_function_demo-aurora-direct_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_direct_group_to_rds_cluster_demo_aurora_group_tcp_5432" {
  security_group_id        = aws_security_group.rds_cluster_demo-aurora_group.id
  source_security_group_id = aws_security_group.lambda_function_demo-aurora-direct_group.id
  description              = "Allow from lambda_function_demo-aurora-direct_group (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_iam_group_egress_all_protocols" {
  security_group_id = aws_security_group.lambda_function_demo-aurora-iam_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_iam_group_to_rds_cluster_demo_aurora_group_tcp_5432" {
  security_group_id        = aws_security_group.rds_cluster_demo-aurora_group.id
  source_security_group_id = aws_security_group.lambda_function_demo-aurora-iam_group.id
  description              = "Allow from lambda_function_demo-aurora-iam_group (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_proxy_group_egress_all_protocols" {
  security_group_id = aws_security_group.lambda_function_demo-aurora-proxy_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lambda_function_demo_aurora_proxy_group_to_db_proxy_demo_aurora_rds_proxy_group_tcp_5432" {
  security_group_id        = aws_security_group.db_proxy_demo-aurora-rds-proxy_group.id
  source_security_group_id = aws_security_group.lambda_function_demo-aurora-proxy_group.id
  description              = "Allow from lambda_function_demo-aurora-proxy_group (tcp:5432-5432)"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_rds_cluster_demo_aurora_group_egress_all_protocols" {
  security_group_id = aws_security_group.rds_cluster_demo-aurora_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_cloudwatch_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-cloudwatch.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_egress_all_protocols" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_sg_vpce_ep_secret_manager_ingress_tcp_443" {
  security_group_id = aws_security_group.sg_vpce_ep-secret-manager.id
  cidr_blocks       = ["10.8.0.0/16"]
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "ingress"
}




### CATEGORY: DATABASE ###

resource "aws_db_proxy" "demo-aurora-rds-proxy" {
  name                           = "demo-aurora-rds-proxy"
  endpoint_network_type          = "IPV4"
  engine_family                  = "POSTGRESQL"
  require_tls                    = true
  role_arn                       = aws_iam_role.role_rds_proxy_demo-aurora-rds-proxy.arn
  target_connection_network_type = "IPV4"
  vpc_security_group_ids         = [aws_security_group.db_proxy_demo-aurora-rds-proxy_group.id]
  vpc_subnet_ids                 = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  auth {
    auth_scheme               = "SECRETS"
    client_password_auth_type = "POSTGRES_SCRAM_SHA_256"
    iam_auth                  = "DISABLED"
    secret_arn                = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
  }
  tags = {
    Name           = "demo-aurora-rds-proxy"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_cloudwatch_log_group.LogGroup, aws_iam_role_policy_attachment.db_proxy_demo-aurora-rds-proxy_st_demo-aurora-state_attach]
}

resource "aws_db_proxy_target" "demo-aurora-rds-proxy_target" {
  db_proxy_name         = aws_db_proxy.demo-aurora-rds-proxy.name
  target_group_name     = "default"
  db_cluster_identifier = aws_rds_cluster.demo-aurora.cluster_identifier
}

resource "aws_db_subnet_group" "subnet_group_demo-aurora" {
  name       = "demo-aurora-subnet-group"
  subnet_ids = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  tags = {
    Name           = "subnet_group_demo-aurora"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_resourcegroupstaggingapi_resources" "cluster_parameter_group_demo-aurora-cluster-params" {
  resource_type_filters = ["rds:cluster-pg"]
  lifecycle {
    postcondition {
      condition     = length(self.resource_tag_mapping_list) > 0
      error_message = "No RDS DB cluster parameter group tagged Name=demo-aurora-cluster-params exists in this region. Apply the state that creates it before this one."
    }
    postcondition {
      condition     = length(self.resource_tag_mapping_list) < 2
      error_message = "More than one RDS DB cluster parameter group is tagged Name=demo-aurora-cluster-params in this region, and this state cannot tell which one to use. Leave one group with that name."
    }
  }
  tag_filter {
    key    = "Name"
    values = ["demo-aurora-cluster-params"]
  }
}

resource "aws_rds_cluster" "demo-aurora" {
  database_name                       = "appdb"
  db_cluster_parameter_group_name     = element(split(":", data.aws_resourcegroupstaggingapi_resources.cluster_parameter_group_demo-aurora-cluster-params.resource_tag_mapping_list[0].resource_arn), 6)
  db_subnet_group_name                = aws_db_subnet_group.subnet_group_demo-aurora.name
  kms_key_id                          = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  apply_immediately                   = true
  backup_retention_period             = 7
  cluster_identifier                  = "demo-aurora"
  copy_tags_to_snapshot               = true
  database_insights_mode              = "standard"
  enable_http_endpoint                = true
  enabled_cloudwatch_logs_exports     = ["iam-db-auth-error", "instance", "postgresql"]
  engine                              = "aurora-postgresql"
  engine_lifecycle_support            = "open-source-rds-extended-support"
  engine_version                      = "16.8"
  iam_database_authentication_enabled = true
  manage_master_user_password         = true
  master_username                     = "dbadmin"
  network_type                        = "IPV4"
  port                                = 5432
  preferred_backup_window             = "08:19-08:49"
  preferred_maintenance_window        = "thu:09:11-thu:09:41"
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  vpc_security_group_ids              = [aws_security_group.rds_cluster_demo-aurora_group.id]
  serverlessv2_scaling_configuration {
    max_capacity             = 2
    min_capacity             = 0
    seconds_until_auto_pause = 300
  }
  tags = {
    Name           = "demo-aurora"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_cloudwatch_log_group.demo-aurora-auth, aws_cloudwatch_log_group.demo-aurora-instance, aws_cloudwatch_log_group.demo-aurora-postgres]
}

data "aws_resourcegroupstaggingapi_resources" "parameter_group_demo-aurora-instance-params" {
  resource_type_filters = ["rds:pg"]
  lifecycle {
    postcondition {
      condition     = length(self.resource_tag_mapping_list) > 0
      error_message = "No RDS DB parameter group tagged Name=demo-aurora-instance-params exists in this region. Apply the state that creates it before this one."
    }
    postcondition {
      condition     = length(self.resource_tag_mapping_list) < 2
      error_message = "More than one RDS DB parameter group is tagged Name=demo-aurora-instance-params in this region, and this state cannot tell which one to use. Leave one group with that name."
    }
  }
  tag_filter {
    key    = "Name"
    values = ["demo-aurora-instance-params"]
  }
}

resource "aws_rds_cluster_instance" "demo-aurora" {
  db_parameter_group_name               = element(split(":", data.aws_resourcegroupstaggingapi_resources.parameter_group_demo-aurora-instance-params.resource_tag_mapping_list[0].resource_arn), 6)
  performance_insights_kms_key_id       = "arn:aws:kms:us-west-2:952133486861:key/e401bcbe-b1b2-4a12-ac7d-cb374176b6fb"
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  cluster_identifier                    = aws_rds_cluster.demo-aurora.id
  copy_tags_to_snapshot                 = true
  engine                                = aws_rds_cluster.demo-aurora.engine
  identifier                            = "demo-aurora"
  instance_class                        = "db.serverless"
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  preferred_backup_window               = "08:19-08:49"
  preferred_maintenance_window          = "tue:06:37-tue:07:07"
  promotion_tier                        = 1
  tags = {
    Name           = "demo-aurora"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_instance" "demo-pgweb" {
  subnet_id                   = aws_subnet.demo-public-a.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.demo-pgweb_profile.name
  instance_type               = "t3.small"
  private_ip                  = "10.8.10.175"
  user_data = <<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="demo-pgweb"
REGION="us-west-2"
ACCOUNT="952133486861"
AWS_RDS_CLUSTER_NAME_0="demo-aurora"
AWS_RDS_CLUSTER_ENGINE_0="aurora-postgresql"
AWS_RDS_CLUSTER_ENDPOINT_0="demo-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
AWS_RDS_CLUSTER_PORT_0="5432"
AWS_RDS_CLUSTER_DB_NAME_0="appdb"
AWS_RDS_CLUSTER_SECRET_ARN_0="arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
AWS_RDS_CLUSTER_ARN_0="arn:aws:rds:us-west-2:952133486861:cluster:demo-aurora"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

#!/bin/bash
# pgweb (web PostgreSQL explorer) on Amazon Linux 2023 via Docker.
# Boots Docker, runs sosedoff/pgweb on port 8081, and keeps it connected across
# Secrets Manager password rotations.
#
# Works with BOTH a plain RDS instance (aws_db_instance) and an Aurora cluster
# (aws_rds_cluster). Struct8 writes different env var names depending on which the EC2
# is wired to: AWS_DB_INSTANCE_* for RDS, AWS_RDS_CLUSTER_* for Aurora. This script
# detects whichever set is present, so one asset serves both templates.
#
# Why pgweb and not a heavier client: pgweb opens ALREADY CONNECTED on the database,
# with no login screen, no setup wizard and no credential for the user to type. The
# instance reads the password from Secrets Manager and starts pgweb pointed at the DB.
#
# ROTATION-SAFE. An RDS/Aurora managed master secret is rotated by AWS -- notably once
# right after the cluster is created. pgweb reads the password once at container start,
# so a fixed password goes stale on rotation and pgweb loops on "authentication failed"
# (the Lambdas never see this: they read the secret on every invocation). To stay
# connected, a systemd timer re-reads the secret every minute and recreates the
# container whenever the live password differs from the one the container is running
# with -- so a rotation self-heals within ~1 minute.
#
# It hardcodes nothing about the account. Struct8 writes the connection details to
# /etc/struct8_env when the instance is wired to the database AND "add environment
# variables" is enabled; this script reads them from there.
#
# Variables read from /etc/struct8_env (one set or the other, auto-detected):
#   RDS instance:   AWS_DB_INSTANCE_ENDPOINT_0 (host:port), AWS_DB_INSTANCE_DB_NAME_0,
#                   AWS_DB_INSTANCE_SECRET_ARN_0
#   Aurora cluster: AWS_RDS_CLUSTER_ENDPOINT_0 (host), AWS_RDS_CLUSTER_PORT_0,
#                   AWS_RDS_CLUSTER_DB_NAME_0, AWS_RDS_CLUSTER_SECRET_ARN_0
#   REGION          region, used for the AWS CLI calls (falls back to instance metadata)
LOGFILE="/var/log/user-data.log"
exec >"$LOGFILE" 2>&1
set -x

PGWEB_PORT="$${PGWEB_PORT:-8081}"
PGWEB_IMAGE="$${PGWEB_IMAGE:-sosedoff/pgweb:latest}"
# sslmode for the connection. RDS/Aurora require TLS; "require" encrypts without
# verifying the CA (fine for a demo). Use "verify-full" with a CA bundle in prod.
PG_SSLMODE="$${PG_SSLMODE:-require}"

echo "Updating the system..."
dnf update -y

echo "Installing Docker..."
dnf install -y docker
systemctl enable docker
systemctl start docker

# --- Resolve the connection details ONCE, from /etc/struct8_env --------------------
if [ -f /etc/struct8_env ]; then
  # shellcheck disable=SC1091
  . /etc/struct8_env
fi

# Detect the wire: Aurora cluster first, then plain RDS instance.
if [ -n "$${AWS_RDS_CLUSTER_ENDPOINT_0:-}" ]; then
  DB_HOST="$${AWS_RDS_CLUSTER_ENDPOINT_0}"       # Aurora: host alone
  DB_PORT="$${AWS_RDS_CLUSTER_PORT_0:-5432}"
  DB_NAME="$${AWS_RDS_CLUSTER_DB_NAME_0:-}"
  DB_SECRET_ARN="$${AWS_RDS_CLUSTER_SECRET_ARN_0:-}"
elif [ -n "$${AWS_DB_INSTANCE_ENDPOINT_0:-}" ]; then
  DB_HOST="$${AWS_DB_INSTANCE_ENDPOINT_0}"       # RDS: host:port
  DB_PORT=""
  DB_NAME="$${AWS_DB_INSTANCE_DB_NAME_0:-}"
  DB_SECRET_ARN="$${AWS_DB_INSTANCE_SECRET_ARN_0:-}"
else
  echo "ERROR: /etc/struct8_env has no database endpoint. Wire the instance to the"
  echo "RDS instance or Aurora cluster and enable 'add environment variables'. Aborting."
  exit 1
fi

AWS_REGION="$${REGION:-$(curl -s --max-time 5 http://169.254.169.254/latest/meta-data/placement/region)}"

if [ -z "$DB_HOST" ] || [ -z "$DB_SECRET_ARN" ]; then
  echo "ERROR: /etc/struct8_env has no database endpoint/secret. Aborting."
  exit 1
fi

# Endpoint may be host:port (RDS) or host (Aurora); split off a port if present.
case "$DB_HOST" in
  *:*)
    DB_PORT="$${DB_HOST##*:}"
    DB_HOST="$${DB_HOST%%:*}"
    ;;
esac
DB_PORT="$${DB_PORT:-5432}"

# --- Install the reconcile script and the systemd timer that keeps pgweb connected -
# The reconcile script is the single source of truth for how pgweb is run; the boot
# path just invokes it once, and the timer invokes it every minute afterwards.
mkdir -p /opt/pgweb
cat > /opt/pgweb/pgweb.env <<EOFPGENV
DB_HOST=$${DB_HOST}
DB_PORT=$${DB_PORT}
DB_NAME=$${DB_NAME}
DB_SECRET_ARN=$${DB_SECRET_ARN}
AWS_REGION=$${AWS_REGION}
PGWEB_PORT=$${PGWEB_PORT}
PGWEB_IMAGE=$${PGWEB_IMAGE}
PG_SSLMODE=$${PG_SSLMODE}
EOFPGENV

cat > /opt/pgweb/reconcile.sh <<'EOFRECONCILE'
#!/bin/bash
# Ensures the pgweb container is running with the CURRENT master password. Reads the
# secret, compares with what the running container holds, and recreates it on any
# mismatch (or if it is not running). Idempotent: a no-op when already correct.
set -u
# shellcheck disable=SC1091
. /opt/pgweb/pgweb.env

SECRET_JSON="$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" --region "$AWS_REGION" \
  --query SecretString --output text 2>/dev/null)" || exit 0
[ -z "$SECRET_JSON" ] && exit 0

DB_USER="$(printf '%s' "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["username"])')" || exit 0
DB_PASS="$(printf '%s' "$SECRET_JSON" | python3 -c 'import sys,json; print(json.load(sys.stdin)["password"])')" || exit 0
[ -z "$DB_PASS" ] && exit 0

# What is the running container using right now?
CUR_PASS="$(docker inspect pgweb --format '{{range .Config.Env}}{{println .}}{{end}}' 2>/dev/null | sed -n 's/^PGWEB_PASS=//p')"
RUNNING="$(docker inspect -f '{{.State.Running}}' pgweb 2>/dev/null || echo false)"

if [ "$RUNNING" = "true" ] && [ "$CUR_PASS" = "$DB_PASS" ]; then
  exit 0   # already correct
fi

echo "$(date -u +%FT%TZ) reconcile: (re)starting pgweb (running=$RUNNING, pass changed=$([ "$CUR_PASS" = "$DB_PASS" ] && echo no || echo yes))"
docker rm -f pgweb >/dev/null 2>&1
# Override the image entrypoint with a shell so $PGWEB_PASS is expanded INSIDE the
# container and never appears in argv/`docker inspect .Args`. Separate flags (not a
# DATABASE_URL): pgweb mis-decodes a percent-encoded password in the URL, so a managed
# secret with /, @, :, |, (, > etc. fails auth when encoded. Raw password avoids that.
docker run -d \
  --name pgweb \
  --restart unless-stopped \
  -p "$${PGWEB_PORT}:8081" \
  -e PGWEB_PASS="$DB_PASS" \
  --entrypoint sh \
  "$PGWEB_IMAGE" \
  -c 'exec pgweb --bind=0.0.0.0 --listen=8081 \
    --host="'"$DB_HOST"'" --port="'"$DB_PORT"'" --user="'"$DB_USER"'" \
    --pass="$PGWEB_PASS" --db="'"$DB_NAME"'" --ssl="'"$PG_SSLMODE"'"'
EOFRECONCILE
chmod +x /opt/pgweb/reconcile.sh

cat > /etc/systemd/system/pgweb-reconcile.service <<'EOFSVC'
[Unit]
Description=Reconcile pgweb container with the current DB master secret
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/opt/pgweb/reconcile.sh
EOFSVC

cat > /etc/systemd/system/pgweb-reconcile.timer <<'EOFTIMER'
[Unit]
Description=Run pgweb reconcile every minute (self-heals on secret rotation)

[Timer]
OnBootSec=15s
OnUnitActiveSec=60s
AccuracySec=10s

[Install]
WantedBy=timers.target
EOFTIMER

systemctl daemon-reload
systemctl enable --now pgweb-reconcile.timer

# Run it once now so pgweb comes up immediately instead of waiting for the first tick.
echo "Starting pgweb on port $${PGWEB_PORT}..."
/opt/pgweb/reconcile.sh

echo "Done. pgweb is starting on port $${PGWEB_PORT}."
echo "Open http://<instance-public-ip>:$${PGWEB_PORT} -- it opens already connected to the database."
echo "A systemd timer re-reads the secret every minute and reconnects pgweb after a rotation."

EOFUData

  vpc_security_group_ids = [aws_security_group.instance_demo-pgweb_group.id]
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  enclave_options {
    enabled = false
  }
  lifecycle {
    ignore_changes = [user_data_replace_on_change]
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  private_dns_name_options {
    enable_resource_name_dns_a_record    = false
    enable_resource_name_dns_aaaa_record = false
    hostname_type                        = "ip-name"
  }
  root_block_device {
    kms_key_id  = "arn:aws:kms:us-west-2:952133486861:key/f019f965-2340-4c77-b976-182a1c3460ab"
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
    tags = {
    Name = "demo-pgweb"
  }
  }
  tags = {
    Name           = "demo-pgweb"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
    Struct8Debug   = "PSH0iot7vZkT3iq-O7LSR"
  }
}

resource "aws_lambda_function" "demo-aurora-dataapi" {
  function_name                  = "demo-aurora-dataapi"
  architectures                  = ["arm64"]
  description                    = "Lambda OUTSIDE the VPC that writes via the Aurora Data API (HTTP + SigV4), running the Struct8 Hub"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-aurora-dataapi_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:demo-aurora"
    AWS_RDS_CLUSTER_DATA_API_0   = true
    AWS_RDS_CLUSTER_DB_NAME_0    = "appdb"
    AWS_RDS_CLUSTER_ENDPOINT_0   = "demo-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
    AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
    AWS_RDS_CLUSTER_NAME_0       = "demo-aurora"
    AWS_RDS_CLUSTER_PORT_0       = "5432"
    AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
    NAME                         = "demo-aurora-dataapi"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-aurora-dataapi"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-aurora-dataapi_st_demo-aurora-state_attach]
}

resource "aws_lambda_function" "demo-aurora-direct" {
  function_name                  = "demo-aurora-direct"
  architectures                  = ["arm64"]
  description                    = "Reaches the Aurora cluster DIRECTLY (writer endpoint, no proxy), running the Struct8 Hub"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-aurora-direct_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:demo-aurora"
    AWS_RDS_CLUSTER_DB_NAME_0    = "appdb"
    AWS_RDS_CLUSTER_ENDPOINT_0   = "demo-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
    AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
    AWS_RDS_CLUSTER_NAME_0       = "demo-aurora"
    AWS_RDS_CLUSTER_PORT_0       = "5432"
    AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
    NAME                         = "demo-aurora-direct"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-aurora-direct"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda_function_demo-aurora-direct_group.id]
    subnet_ids         = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-aurora-direct_st_demo-aurora-state_attach]
}

resource "aws_lambda_function" "demo-aurora-iam" {
  function_name                  = "demo-aurora-iam"
  architectures                  = ["arm64"]
  description                    = "Reaches the Aurora cluster with IAM DATABASE AUTH (short-lived token, no stored password), running the Struct8 Hub"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-aurora-iam_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_RDS_CLUSTER_ARN_0        = "arn:aws:rds:us-west-2:952133486861:cluster:demo-aurora"
    AWS_RDS_CLUSTER_DB_NAME_0    = "appdb"
    AWS_RDS_CLUSTER_ENDPOINT_0   = "demo-aurora.cluster-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
    AWS_RDS_CLUSTER_ENGINE_0     = "aurora-postgresql"
    AWS_RDS_CLUSTER_IAM_USER_0   = "lambda_iam"
    AWS_RDS_CLUSTER_NAME_0       = "demo-aurora"
    AWS_RDS_CLUSTER_PORT_0       = "5432"
    AWS_RDS_CLUSTER_SECRET_ARN_0 = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
    NAME                         = "demo-aurora-iam"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-aurora-iam"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda_function_demo-aurora-iam_group.id]
    subnet_ids         = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-aurora-iam_st_demo-aurora-state_attach]
}

resource "aws_lambda_function" "demo-aurora-proxy" {
  function_name                  = "demo-aurora-proxy"
  architectures                  = ["arm64"]
  description                    = "Reaches the Aurora cluster THROUGH THE RDS PROXY (connection pooling), running the Struct8 Hub"
  filename                       = "imported_lambda_placeholder.zip"
  handler                        = "index.handler"
  memory_size                    = 2000
  publish                        = false
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.demo-aurora-proxy_role.arn
  runtime                        = "nodejs22.x"
  timeout                        = 30
  environment {
    variables = {
    ACCOUNT                      = "952133486861"
    AWS_DB_PROXY_DB_NAME_0       = "appdb"
    AWS_DB_PROXY_ENDPOINT_0      = "demo-aurora-rds-proxy.proxy-c9g6oy6oylb0.us-west-2.rds.amazonaws.com"
    AWS_DB_PROXY_ENGINE_FAMILY_0 = "POSTGRESQL"
    AWS_DB_PROXY_NAME_0          = "demo-aurora-rds-proxy"
    AWS_DB_PROXY_PORT_0          = "5432"
    AWS_DB_PROXY_SECRET_ARN_0    = "arn:aws:secretsmanager:us-west-2:952133486861:secret:rds!cluster-4fc39f33-b4c0-460a-b820-d5dac14539a0-Wc3lQY"
    NAME                         = "demo-aurora-proxy"
    REGION                       = "us-west-2"
  }
  }
  ephemeral_storage {
    size = 512
  }
  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }
  logging_config {
    log_format = "Text"
  }
  tags = {
    Name           = "demo-aurora-proxy"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    security_group_ids = [aws_security_group.lambda_function_demo-aurora-proxy_group.id]
    subnet_ids         = [aws_subnet.demo-aurora-private-a.id, aws_subnet.demo-aurora-private-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.lambda_function_demo-aurora-proxy_st_demo-aurora-state_attach]
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-dataapi" {
  function_name = aws_lambda_function.demo-aurora-dataapi.function_name
  statement_id  = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-dataapid7143abfc1956d463357c8a163"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudwatch_event_rule.every-1-minute.arn
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-direct" {
  function_name = aws_lambda_function.demo-aurora-direct.function_name
  statement_id  = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-direct90f9daece65706ddf747584f65"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudwatch_event_rule.every-1-minute.arn
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-iam" {
  function_name = aws_lambda_function.demo-aurora-iam.function_name
  statement_id  = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-iam92d64e72f237c34e90f31f2058"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudwatch_event_rule.every-1-minute.arn
}

resource "aws_lambda_permission" "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-proxy" {
  function_name = aws_lambda_function.demo-aurora-proxy.function_name
  statement_id  = "perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-proxy084a8c645e23b382e9b649dfad"
  principal     = "events.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = aws_cloudwatch_event_rule.every-1-minute.arn
}




### CATEGORY: INTEGRATION ###

resource "aws_cloudwatch_event_rule" "every-1-minute" {
  name                = "every-1-minute"
  schedule_expression = "rate(1 minute)"
  state               = "ENABLED"
  tags = {
    Name           = "every-1-minute"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_event_target" "Target" {
  target_id  = "terraform-nNC7dphP0WECsUTbo2bHZzvyVK"
  arn        = aws_lambda_function.demo-aurora-direct.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-direct]
}

resource "aws_cloudwatch_event_target" "Target1" {
  target_id  = "terraform-RJ9fkD5mNI4wKESmEbycGUDf7j"
  arn        = aws_lambda_function.demo-aurora-proxy.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-proxy]
}

resource "aws_cloudwatch_event_target" "Target2" {
  target_id  = "terraform-gn4y9YIB10thyM4AZdHzUomyVE"
  arn        = aws_lambda_function.demo-aurora-iam.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-iam]
}

resource "aws_cloudwatch_event_target" "Target3" {
  target_id  = "terraform-64X9bpNCiIAiTI42yTZUfk3nGb"
  arn        = aws_lambda_function.demo-aurora-dataapi.arn
  rule       = aws_cloudwatch_event_rule.every-1-minute.name
  depends_on = [aws_lambda_permission.perm_aws_cloudwatch_event_rule_every-1-minute_to_demo-aurora-dataapi]
}




### CATEGORY: MONITORING ###

resource "aws_cloudwatch_log_group" "LogGroup" {
  name              = "/aws/rds/proxy/demo-aurora-rds-proxy"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "LogGroup"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-auth" {
  name              = "/aws/rds/cluster/demo-aurora/iam-db-auth-error"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-aurora-auth"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-dataapi-logs" {
  name              = "/aws/lambda/demo-aurora-dataapi"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  tags = {
    Name           = "demo-aurora-dataapi-logs"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-direct-logs" {
  name              = "/aws/lambda/demo-aurora-direct"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-aurora-direct-logs"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-iam-logs" {
  name              = "/aws/lambda/demo-aurora-iam"
  log_group_class   = "STANDARD"
  retention_in_days = 30
  tags = {
    Name           = "demo-aurora-iam-logs"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-instance" {
  name              = "/aws/rds/cluster/demo-aurora/instance"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-aurora-instance"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-postgres" {
  name              = "/aws/rds/cluster/demo-aurora/postgresql"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-aurora-postgres"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_cloudwatch_log_group" "demo-aurora-proxy-logs" {
  name              = "/aws/lambda/demo-aurora-proxy"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  tags = {
    Name           = "demo-aurora-proxy-logs"
    State          = "demo-aurora-state"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: CONFIG ###

resource "aws_ssm_document" "Struct8Probe-Debug" {
  name = "Struct8Probe-PSH0iot7vZkT3iq-O7LSR"
  content = <<EOF
{
  "schemaVersion": "2.2",
  "description": "Struct8 network probe. The command text is fixed here; the caller supplies only a target and a port.",
  "parameters": {
    "target": {
      "type": "String",
      "description": "Hostname or IP address to probe.",
      "interpolationType": "ENV_VAR",
      "allowedPattern": "^[A-Za-z0-9._-]{1,253}$"
    },
    "port": {
      "type": "String",
      "description": "TCP port to test.",
      "default": "443",
      "interpolationType": "ENV_VAR",
      "allowedPattern": "^[0-9]{1,5}$"
    }
  },
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "struct8Probe",
      "inputs": {
        "timeoutSeconds": "60",
        "runCommand": [
          "if [ -z \"$SSM_target\" ]; then export SSM_target=\"{{target}}\"; fi",
          "if [ -z \"$SSM_port\" ]; then export SSM_port=\"{{port}}\"; fi",
          "echo '--- resolve ---'",
          "getent hosts \"$SSM_target\" || echo \"no DNS answer\"",
          "echo '--- icmp ---'",
          "ping -c 3 -W 2 \"$SSM_target\" || echo \"no ICMP reply (often filtered, not conclusive)\"",
          "echo '--- tcp ---'",
          "if timeout 5 bash -c 'exec 3<>/dev/tcp/\"$1\"/\"$2\"' _ \"$SSM_target\" \"$SSM_port\" 2>/dev/null; then echo \"port $SSM_port open\"; else echo \"port $SSM_port closed or filtered\"; fi"
        ]
      }
    }
  ]
}
  EOF
  document_format = "JSON"
  document_type   = "Command"
}


