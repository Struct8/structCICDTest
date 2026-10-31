terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/zonal-2-addresses-state/main.tfstate"
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

resource "aws_vpc" "zonal-2-addresses-vpc" {
  cidr_block       = "10.103.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "zonal-2-addresses-vpc"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-2-addresses-private-a" {
  vpc_id                  = aws_vpc.zonal-2-addresses-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.103.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "zonal-2-addresses-private-a"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "zonal-2-addresses-public-a" {
  vpc_id                  = aws_vpc.zonal-2-addresses-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.103.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "zonal-2-addresses-public-a"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "zonal-2-addresses-igw" {
  vpc_id = aws_vpc.zonal-2-addresses-vpc.id
  tags = {
    Name           = "zonal-2-addresses-igw"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "zonal-2-addresses-nat" {
  allocation_id            = aws_eip.zonal-2-addresses-eip-primary.id
  subnet_id                = aws_subnet.zonal-2-addresses-public-a.id
  availability_mode        = "zonal"
  secondary_allocation_ids = [aws_eip.zonal-2-addresses-eip-secondary.id]
  tags = {
    Name           = "zonal-2-addresses-nat"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.zonal-2-addresses-igw]
}

resource "aws_route" "route_zonal-2-addresses-rt-private_to_zonal-2-addresses-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.zonal-2-addresses-nat.id
  route_table_id         = aws_route_table.zonal-2-addresses-rt-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_zonal-2-addresses-rt-public_to_zonal-2-addresses-igw_ipv4" {
  gateway_id             = aws_internet_gateway.zonal-2-addresses-igw.id
  route_table_id         = aws_route_table.zonal-2-addresses-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "zonal-2-addresses-rt-private" {
  vpc_id = aws_vpc.zonal-2-addresses-vpc.id
  tags = {
    Name           = "zonal-2-addresses-rt-private"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "zonal-2-addresses-rt-public" {
  vpc_id = aws_vpc.zonal-2-addresses-vpc.id
  tags = {
    Name           = "zonal-2-addresses-rt-public"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_zonal_2_addresses_private_a_zonal_2_addresses_rt_private" {
  route_table_id = aws_route_table.zonal-2-addresses-rt-private.id
  subnet_id      = aws_subnet.zonal-2-addresses-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_zonal_2_addresses_public_a_zonal_2_addresses_rt_public" {
  route_table_id = aws_route_table.zonal-2-addresses-rt-public.id
  subnet_id      = aws_subnet.zonal-2-addresses-public-a.id
}

resource "aws_eip" "zonal-2-addresses-eip-primary" {
  tags = {
    Name           = "zonal-2-addresses-eip-primary"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eip" "zonal-2-addresses-eip-secondary" {
  tags = {
    Name           = "zonal-2-addresses-eip-secondary"
    State          = "zonal-2-addresses-state"
    Struct8Creator = "rmay struct"
  }
}


