terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/StatepeervpcA/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "Instance1_profile" {
  name                              = "Instance1_profile"
  role                              = aws_iam_role.Instance1_role.name
  tags                              = {
    Name = "Instance1_profile"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

data "aws_iam_policy_document" "Debug_debug_permissions" {
  statement {
    sid                             = "SendToTaggedInstancesOnly"
    effect                          = "Allow"
    actions                         = ["ssm:SendCommand"]
    resources                       = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test                          = "StringEquals"
      values                        = ["Debug"]
      variable                      = "aws:ResourceTag/Struct8Debug"
    }
  }
  statement {
    sid                             = "PinnedDocumentOnly"
    effect                          = "Allow"
    actions                         = ["ssm:SendCommand"]
    resources                       = ["arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:document/Struct8Probe-Debug"]
  }
  statement {
    sid                             = "ReadOwnResults"
    effect                          = "Allow"
    actions                         = ["ssm:GetCommandInvocation", "ssm:DescribeInstanceInformation"]
    resources                       = ["*"]
  }
  statement {
    sid                             = "CancelOnTaggedInstancesOnly"
    effect                          = "Allow"
    actions                         = ["ssm:CancelCommand"]
    resources                       = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test                          = "StringEquals"
      values                        = ["Debug"]
      variable                      = "aws:ResourceTag/Struct8Debug"
    }
  }
}

data "aws_iam_policy_document" "Debug_debug_trust" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CrossAccountStruct8"]
      type                          = "AWS"
    }
    actions                         = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "Instance1_role" {
  name                              = "Instance1_role"
  assume_role_policy                = jsonencode({
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
  force_detach_policies             = false
  max_session_duration              = 3600
  path                              = "/"
  tags                              = {
    Name = "Instance1_role"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_iam_role" "Struct8Debug-Debug" {
  name                              = "Struct8Debug-Debug"
  assume_role_policy                = data.aws_iam_policy_document.Debug_debug_trust.json
  max_session_duration              = 3600
}

resource "aws_iam_role_policy" "Struct8Debug-Debug_policy" {
  name                              = "Struct8Debug-Debug-policy"
  policy                            = data.aws_iam_policy_document.Debug_debug_permissions.json
  role                              = aws_iam_role.Struct8Debug-Debug.id
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore_to_Instance1_attach" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role                              = aws_iam_role.Instance1_role.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC" {
  cidr_block                        = "10.10.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                            = aws_vpc.VPC.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.10.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "Subnet2"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC.id
  tags                              = {
    Name = "IGW"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_route" "route_RT_to_IGW_ipv4" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_RT_to_IGW_ipv6" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT.id
  destination_ipv6_cidr_block       = "::/0"
}

resource "aws_route_table" "RT" {
  vpc_id                            = aws_vpc.VPC.id
  tags                              = {
    Name = "RT"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet2_RT" {
  route_table_id                    = aws_route_table.RT.id
  subnet_id                         = aws_subnet.Subnet2.id
}

resource "aws_security_group" "instance_Instance1_group" {
  name                              = "instance_Instance1_group"
  vpc_id                            = aws_vpc.VPC.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "instance_Instance1_group"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_Instance1_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.instance_Instance1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Instance1" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_instance" "Instance1" {
  subnet_id                         = aws_subnet.Subnet2.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance1.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.Instance1_profile.name
  instance_type                     = "t4g.nano"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.instance_Instance1_group.id]
  instance_market_options {
    market_type                     = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type            = "one-time"
    }
  }
  metadata_options {
    http_endpoint                   = "enabled"
    http_tokens                     = "required"
  }
  tags                              = {
    Struct8Debug = "Debug"
    Name = "Instance1"
    State = "StatepeervpcA"
    Struct8User = "rmay struct"
  }
}




### CATEGORY: MISC ###

resource "aws_ssm_document" "Struct8Probe-Debug" {
  name                              = "Struct8Probe-Debug"
  content                           = <<EOF
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
  document_format                   = "JSON"
  document_type                     = "Command"
}


