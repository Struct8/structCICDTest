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
    key            = "952133486861/State3snsteste/main.tfstate"
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
  tags                              = {
    Name = "Instance1_profile"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC1" {
  cidr_block                        = "10.10.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC1"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.10.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Subnet2"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group" "instance_Instance1_group" {
  name                              = "instance_Instance1_group"
  vpc_id                            = aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "instance_Instance1_group"
    State = "State3snsteste"
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
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance1" {
  subnet_id                         = aws_subnet.Subnet2.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance1.id
  associate_public_ip_address       = false
  iam_instance_profile              = aws_iam_instance_profile.Instance1_profile.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.instance_Instance1_group.id]
  metadata_options {
    http_endpoint                   = "enabled"
    http_tokens                     = "required"
  }
  tags                              = {
    Name = "Instance1"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}


