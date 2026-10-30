terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/VPC-Monitoring/main.tfstate"
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

### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC-Monitoring" {
  cidr_block         = "10.5.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "VPC-Monitoring"
    State          = "State-VPC-Monitoring"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "subnet-private-a" {
  vpc_id                              = aws_vpc.VPC-Monitoring.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.5.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "subnet-private-a"
    State          = "State-VPC-Monitoring"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "subnet-public-a" {
  vpc_id                              = aws_vpc.VPC-Monitoring.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.5.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "subnet-public-a"
    State          = "State-VPC-Monitoring"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "RT-private-a" {
  vpc_id = aws_vpc.VPC-Monitoring.id
  tags = {
    Name           = "RT-private-a"
    State          = "State-VPC-Monitoring"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "RT-public-a" {
  vpc_id = aws_vpc.VPC-Monitoring.id
  tags = {
    Name           = "RT-public-a"
    State          = "State-VPC-Monitoring"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_subnet_private_a_RT_private_a" {
  route_table_id = aws_route_table.RT-private-a.id
  subnet_id      = aws_subnet.subnet-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_subnet_public_a_RT_public_a" {
  route_table_id = aws_route_table.RT-public-a.id
  subnet_id      = aws_subnet.subnet-public-a.id
}


