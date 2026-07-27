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
    key            = "952133486861/Statepeer/main.tfstate"
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

resource "aws_vpc" "VPC" {
  cidr_block                        = "10.10.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC"
    State = "Statepeer"
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
    State = "Statepeer"
    Struct8User = "rmay struct"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.VPC.id
  tags                              = {
    Name = "IGW"
    State = "Statepeer"
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
    State = "Statepeer"
    Struct8User = "rmay struct"
  }
}


