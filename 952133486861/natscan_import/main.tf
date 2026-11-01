terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/natscan_import/main.tfstate"
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
  path = "/"
  role = aws_iam_role.kuma_role.name
  tags = {
    Name           = "kuma_profile"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "nat_profile" {
  name = "nat_profile"
  path = "/"
  role = aws_iam_role.nat_role.name
  tags = {
    Name           = "nat_profile"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "kuma_role" {
  name                  = "kuma_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
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
  name                  = "nat_role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
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
  cidr_block         = "10.4.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "ec2-nat-private"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private" {
  vpc_id                              = aws_vpc.ec2-nat-private.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.4.2.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public" {
  vpc_id                              = aws_vpc.ec2-nat-private.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.4.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
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
  name        = "instance_kuma_group"
  vpc_id      = aws_vpc.ec2-nat-private.id
  description = "Uptime Kuma public access"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "instance_kuma_group"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat_group" {
  name        = "instance_nat_group"
  vpc_id      = aws_vpc.ec2-nat-private.id
  description = "NAT instance"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
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

resource "aws_instance" "kuma" {
  subnet_id                   = aws_subnet.private.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.kuma_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.4.2.10"
  vpc_security_group_ids      = [aws_security_group.instance_kuma_group.id]
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
    ignore_changes = [user_data, user_data_replace_on_change]
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
    Name = "kuma"
  }
  }
  tags = {
    Name           = "kuma"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_instance" "nat" {
  subnet_id                   = aws_subnet.public.id
  ami                         = "ami-0cc098d14c47f965b"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.4.1.193"
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.instance_nat_group.id]
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
    ignore_changes = [user_data, user_data_replace_on_change]
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
    Name = "nat"
  }
  }
  tags = {
    Name           = "nat"
    State          = "ec2-nat-private"
    Struct8Creator = "rmay struct"
  }
}


