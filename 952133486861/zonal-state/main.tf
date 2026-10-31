terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/zonal-state/main.tfstate"
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

resource "aws_iam_instance_profile" "Instance_profile" {
  name = "Instance_profile"
  role = aws_iam_role.Instance_role.name
  tags = {
    Name           = "Instance_profile"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "Instance_role" {
  name = "Instance_role"
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
    Name           = "Instance_role"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "nat-instance-zonal-vpc" {
  cidr_block       = "10.105.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "nat-instance-zonal-vpc"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-private-a" {
  vpc_id                  = aws_vpc.nat-instance-zonal-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.105.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "zonal-private-a"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-public-a" {
  vpc_id                  = aws_vpc.nat-instance-zonal-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.105.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "zonal-public-a"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "zonal-igw" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-igw"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_zonal-rt-private_to_Instance_ipv4" {
  network_interface_id   = aws_instance.Instance.primary_network_interface_id
  route_table_id         = aws_route_table.zonal-rt-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_zonal-rt-public_to_zonal-igw_ipv4" {
  gateway_id             = aws_internet_gateway.zonal-igw.id
  route_table_id         = aws_route_table.zonal-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "zonal-rt-private" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-rt-private"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "zonal-rt-public" {
  vpc_id = aws_vpc.nat-instance-zonal-vpc.id
  tags = {
    Name           = "zonal-rt-public"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_zonal_private_a_zonal_rt_private" {
  route_table_id = aws_route_table.zonal-rt-private.id
  subnet_id      = aws_subnet.zonal-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_zonal_public_a_zonal_rt_public" {
  route_table_id = aws_route_table.zonal-rt-public.id
  subnet_id      = aws_subnet.zonal-public-a.id
}

resource "aws_security_group" "instance_Instance_group" {
  name                   = "instance_Instance_group"
  vpc_id                 = aws_vpc.nat-instance-zonal-vpc.id
  description            = "Accepts every protocol from the VPC CIDR, which is the traffic this NAT instance forwards. Egress open."
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_Instance_group"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_Instance_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_Instance_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_Instance_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_Instance_group.id
  cidr_blocks       = ["10.105.0.0/16"]
  description       = "Traffic from the VPC that the private route table sends here"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_eip" "EIP" {
  instance = aws_instance.Instance.id
  tags = {
    Name           = "EIP"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.zonal-igw]
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Instance" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_Instance" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance" {
  subnet_id                   = aws_subnet.zonal-public-a.id
  ami                         = data.aws_ami.AMI_Data_Source_Instance.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.Instance_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_Instance.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_Instance_group.id]
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
    Name           = "Instance"
    State          = "zonal-state"
    Struct8Creator = "rmay struct"
  }
}


