terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/vpc-dual-stack-lab/main.tfstate"
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

resource "aws_iam_instance_profile" "private-host_profile" {
  name = "private-host_profile"
  role = aws_iam_role.private-host_role.name
  tags = {
    Name           = "private-host_profile"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "public-host_profile" {
  name = "public-host_profile"
  role = aws_iam_role.public-host_role.name
  tags = {
    Name           = "public-host_profile"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "private-host_role" {
  name = "private-host_role"
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
    Name           = "private-host_role"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "public-host_role" {
  name = "public-host_role"
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
    Name           = "public-host_role"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "vpc-dual-stack-lab" {
  assign_generated_ipv6_cidr_block = true
  cidr_block                       = "10.3.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    Name           = "vpc-dual-stack-lab"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id                          = aws_vpc.vpc-dual-stack-lab.id
  assign_ipv6_address_on_creation = true
  availability_zone               = "us-west-2a"
  cidr_block                      = "10.3.10.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc-dual-stack-lab.ipv6_cidr_block, 8, 0)
  map_public_ip_on_launch         = false
  tags = {
    Name           = "private-a"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id                          = aws_vpc.vpc-dual-stack-lab.id
  assign_ipv6_address_on_creation = true
  availability_zone               = "us-west-2b"
  cidr_block                      = "10.3.11.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc-dual-stack-lab.ipv6_cidr_block, 8, 1)
  map_public_ip_on_launch         = false
  tags = {
    Name           = "private-b"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                          = aws_vpc.vpc-dual-stack-lab.id
  assign_ipv6_address_on_creation = true
  availability_zone               = "us-west-2a"
  cidr_block                      = "10.3.0.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc-dual-stack-lab.ipv6_cidr_block, 8, 2)
  map_public_ip_on_launch         = true
  tags = {
    Name           = "public-a"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                          = aws_vpc.vpc-dual-stack-lab.id
  assign_ipv6_address_on_creation = true
  availability_zone               = "us-west-2b"
  cidr_block                      = "10.3.1.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc-dual-stack-lab.ipv6_cidr_block, 8, 3)
  map_public_ip_on_launch         = true
  tags = {
    Name           = "public-b"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-dual-stack-lab.id
  tags = {
    Name           = "igw"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.vpc-dual-stack-lab.id
  tags = {
    Name           = "eigw"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "Regional-nat" {
  vpc_id            = aws_vpc.vpc-dual-stack-lab.id
  availability_mode = "regional"
  connectivity_type = "public"
  tags = {
    Name           = "Regional-nat"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "route_private_to_Regional-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.Regional-nat.id
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_private_to_eigw_ipv6" {
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_route" "route_public_to_igw_ipv4" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_public_to_igw_ipv6" {
  gateway_id                  = aws_internet_gateway.igw.id
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc-dual-stack-lab.id
  tags = {
    Name           = "private"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc-dual-stack-lab.id
  tags = {
    Name           = "public"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_a_private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_private_b_private" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_public_a_public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_public_b_public" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public-b.id
}

resource "aws_security_group" "instance_private-host_group" {
  name                   = "instance_private-host_group"
  vpc_id                 = aws_vpc.vpc-dual-stack-lab.id
  description            = "Dual-stack lab host in a private subnet"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_private-host_group"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_public-host_group" {
  name                   = "instance_public-host_group"
  vpc_id                 = aws_vpc.vpc-dual-stack-lab.id
  description            = "Dual-stack lab host in a public subnet"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_public-host_group"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_private_host_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_private-host_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound over IPv4 and IPv6"
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_private_host_group_ingress_icmp__1" {
  security_group_id = aws_security_group.instance_private-host_group.id
  cidr_blocks       = ["10.3.0.0/16"]
  description       = "ICMP echo from inside the VPC over IPv4"
  from_port         = -1
  protocol          = "icmp"
  to_port           = -1
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_private_host_group_ingress_icmpv6__1" {
  security_group_id = aws_security_group.instance_private-host_group.id
  description       = "ICMP echo from inside the VPC over IPv6"
  from_port         = -1
  ipv6_cidr_blocks  = [aws_vpc.vpc-dual-stack-lab.ipv6_cidr_block]
  protocol          = "icmpv6"
  to_port           = -1
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_public_host_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_public-host_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound over IPv4 and IPv6"
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_public_host_group_ingress_icmp__1" {
  security_group_id = aws_security_group.instance_public-host_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "ICMP echo over IPv4"
  from_port         = -1
  protocol          = "icmp"
  to_port           = -1
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_public_host_group_ingress_icmpv6__1" {
  security_group_id = aws_security_group.instance_public-host_group.id
  description       = "ICMP echo over IPv6"
  from_port         = -1
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "icmpv6"
  to_port           = -1
  type              = "ingress"
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_private-host" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "private-host" {
  subnet_id                   = aws_subnet.private-a.id
  ami                         = data.aws_ami.AMI_Data_Source_private-host.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.private-host_profile.name
  instance_type               = "t3.nano"
  vpc_security_group_ids      = [aws_security_group.instance_private-host_group.id]
  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
    http_tokens        = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "private-host"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}

data "aws_ami" "AMI_Data_Source_public-host" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "public-host" {
  subnet_id                   = aws_subnet.public-a.id
  ami                         = data.aws_ami.AMI_Data_Source_public-host.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.public-host_profile.name
  instance_type               = "t3.nano"
  vpc_security_group_ids      = [aws_security_group.instance_public-host_group.id]
  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
    http_tokens        = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "public-host"
    State          = "vpc-dual-stack-lab"
    Struct8Creator = "rmay struct"
  }
}


