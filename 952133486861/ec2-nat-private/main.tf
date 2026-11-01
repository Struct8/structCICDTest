terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/ec2-nat-private/main.tfstate"
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

resource "aws_iam_instance_profile" "kuma_profile" {
  name = "kuma_profile"
  role = aws_iam_role.kuma_role.name
  tags = {
    Name           = "kuma_profile"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "nat_profile" {
  name = "nat_profile"
  role = aws_iam_role.nat_role.name
  tags = {
    Name           = "nat_profile"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "kuma_role" {
  name = "kuma_role"
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
    Name           = "kuma_role"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "nat_role" {
  name = "nat_role"
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
    Name           = "nat_role"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "ec2-nat-private" {
  cidr_block       = "10.4.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "ec2-nat-private"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.ec2-nat-private.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.4.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "private"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ec2-nat-private.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.4.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "igw"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_private-rt_to_nat_ipv4" {
  network_interface_id   = aws_instance.nat.primary_network_interface_id
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_public-rt_to_igw_ipv4" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "private-rt"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.ec2-nat-private.id
  tags = {
    Name           = "public-rt"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_private_rt" {
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private.id
}

resource "aws_route_table_association" "aws_route_table_association_public_public_rt" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "instance_kuma_group" {
  name                   = "instance_kuma_group"
  vpc_id                 = aws_vpc.ec2-nat-private.id
  description            = "Uptime Kuma public access"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_kuma_group"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat_group" {
  name                   = "instance_nat_group"
  vpc_id                 = aws_vpc.ec2-nat-private.id
  description            = "NAT instance"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat_group"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_kuma_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_kuma_group_ingress_tcp_3001" {
  security_group_id = aws_security_group.instance_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kuma web UI"
  from_port         = 3001
  protocol          = "tcp"
  to_port           = 3001
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["10.4.0.0/16"]
  description       = "All from VPC"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_group_ingress_tcp_3001" {
  security_group_id = aws_security_group.instance_nat_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kuma UI (forwarded to private)"
  from_port         = 3001
  protocol          = "tcp"
  to_port           = 3001
  type              = "ingress"
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_kuma" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Kuma.sh"
}

data "aws_ami" "AMI_Data_Source_kuma" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "kuma" {
  subnet_id                   = aws_subnet.private.id
  ami                         = data.aws_ami.AMI_Data_Source_kuma.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.kuma_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.4.2.10"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_kuma.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_kuma_group.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "kuma"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_nat" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_nat" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "nat" {
  subnet_id                   = aws_subnet.public.id
  ami                         = data.aws_ami.AMI_Data_Source_nat.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
FORWARD_PORT="3001"
FORWARD_TARGET="10.4.2.10"
NAME="nat"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_nat.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_nat_group.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "nat"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}


