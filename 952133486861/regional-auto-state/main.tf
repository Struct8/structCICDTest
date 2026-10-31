terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/regional-auto-state/main.tfstate"
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

resource "aws_vpc" "regional-auto-vpc" {
  cidr_block       = "10.101.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "regional-auto-vpc"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-auto-private-a" {
  vpc_id                  = aws_vpc.regional-auto-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.101.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "regional-auto-private-a"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-auto-private-b" {
  vpc_id                  = aws_vpc.regional-auto-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.101.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "regional-auto-private-b"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-auto-public-a" {
  vpc_id                  = aws_vpc.regional-auto-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.101.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "regional-auto-public-a"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-auto-public-b" {
  vpc_id                  = aws_vpc.regional-auto-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.101.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "regional-auto-public-b"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "regional-auto-igw" {
  vpc_id = aws_vpc.regional-auto-vpc.id
  tags = {
    Name           = "regional-auto-igw"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "regional-auto-nat" {
  vpc_id            = aws_vpc.regional-auto-vpc.id
  availability_mode = "regional"
  connectivity_type = "public"
  tags = {
    Name           = "regional-auto-nat"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.regional-auto-igw]
}

resource "aws_route" "route_regional-auto-rt-private_to_regional-auto-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.regional-auto-nat.id
  route_table_id         = aws_route_table.regional-auto-rt-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_regional-auto-rt-public_to_regional-auto-igw_ipv4" {
  gateway_id             = aws_internet_gateway.regional-auto-igw.id
  route_table_id         = aws_route_table.regional-auto-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "regional-auto-rt-private" {
  vpc_id = aws_vpc.regional-auto-vpc.id
  tags = {
    Name           = "regional-auto-rt-private"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "regional-auto-rt-public" {
  vpc_id = aws_vpc.regional-auto-vpc.id
  tags = {
    Name           = "regional-auto-rt-public"
    State          = "regional-auto-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_regional_auto_private_a_regional_auto_rt_private" {
  route_table_id = aws_route_table.regional-auto-rt-private.id
  subnet_id      = aws_subnet.regional-auto-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_auto_private_b_regional_auto_rt_private" {
  route_table_id = aws_route_table.regional-auto-rt-private.id
  subnet_id      = aws_subnet.regional-auto-private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_auto_public_a_regional_auto_rt_public" {
  route_table_id = aws_route_table.regional-auto-rt-public.id
  subnet_id      = aws_subnet.regional-auto-public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_auto_public_b_regional_auto_rt_public" {
  route_table_id = aws_route_table.regional-auto-rt-public.id
  subnet_id      = aws_subnet.regional-auto-public-b.id
}


