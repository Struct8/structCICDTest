terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/private-nat-vpc/main.tfstate"
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

resource "aws_vpc" "private-nat-vpc" {
  cidr_block         = "10.104.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "private-nat-vpc"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-nat-app-a" {
  vpc_id                              = aws_vpc.private-nat-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.104.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-nat-app-a"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-nat-subnet-a" {
  vpc_id                              = aws_vpc.private-nat-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.104.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-nat-subnet-a"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "private-nat" {
  subnet_id         = aws_subnet.private-nat-subnet-a.id
  availability_mode = "zonal"
  connectivity_type = "private"
  private_ip        = "10.104.0.13"
  tags = {
    Name           = "private-nat"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_private-nat-rt-app_to_private-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.private-nat.id
  route_table_id         = aws_route_table.private-nat-rt-app.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private-nat-rt" {
  vpc_id = aws_vpc.private-nat-vpc.id
  tags = {
    Name           = "private-nat-rt"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "private-nat-rt-app" {
  vpc_id = aws_vpc.private-nat-vpc.id
  tags = {
    Name           = "private-nat-rt-app"
    State          = "private-nat-vpc"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_nat_app_a_private_nat_rt_app" {
  route_table_id = aws_route_table.private-nat-rt-app.id
  subnet_id      = aws_subnet.private-nat-app-a.id
}

resource "aws_route_table_association" "aws_route_table_association_private_nat_subnet_a_private_nat_rt" {
  route_table_id = aws_route_table.private-nat-rt.id
  subnet_id      = aws_subnet.private-nat-subnet-a.id
}


