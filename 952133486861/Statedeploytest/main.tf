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
    key            = "952133486861/Statedeploytest/main.tfstate"
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

### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC1" {
  cidr_block                        = "10.1.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC1"
    State = "Statedeploytest"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Subnet2" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.1.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Subnet2"
    State = "Statedeploytest"
    Struct8User = "rmay struct"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    Name = "IGW"
    State = "Statedeploytest"
    Struct8User = "rmay struct"
  }
}

resource "aws_route" "route_RT1_to_IGW_ipv4" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT1.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_RT1_to_IGW_ipv6" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT1.id
  destination_ipv6_cidr_block       = "::/0"
}

resource "aws_route_table" "RT1" {
  vpc_id                            = aws_vpc.VPC1.id
  tags                              = {
    Name = "RT1"
    State = "Statedeploytest"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet2_RT1" {
  route_table_id                    = aws_route_table.RT1.id
  subnet_id                         = aws_subnet.Subnet2.id
}


