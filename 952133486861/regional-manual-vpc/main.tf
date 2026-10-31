terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/regional-manual-vpc/main.tfstate"
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

resource "aws_vpc" "regional-manual-vpc" {
  cidr_block         = "10.102.0.0/16"
  enable_dns_support = true
  instance_tenancy   = "default"
  tags = {
    Name           = "regional-manual-vpc"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-manual-private-a" {
  vpc_id                              = aws_vpc.regional-manual-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.102.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "regional-manual-private-a"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-manual-private-b" {
  vpc_id                              = aws_vpc.regional-manual-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.102.2.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "regional-manual-private-b"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-manual-public-a" {
  vpc_id                              = aws_vpc.regional-manual-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.102.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "regional-manual-public-a"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "regional-manual-public-b" {
  vpc_id                              = aws_vpc.regional-manual-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.102.3.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "regional-manual-public-b"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "regional-manual-igw" {
  vpc_id = aws_vpc.regional-manual-vpc.id
  tags = {
    Name           = "regional-manual-igw"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "regional-manual-nat" {
  vpc_id            = aws_vpc.regional-manual-vpc.id
  availability_mode = "regional"
  connectivity_type = "public"
  availability_zone_address {
    allocation_ids    = [aws_eip.regional-manual-eip-az-a.id, aws_eip.regional-manual-eip-az-a-extra.id]
    availability_zone = "us-west-2a"
  }
  availability_zone_address {
    allocation_ids    = [aws_eip.regional-manual-eip-az-b.id]
    availability_zone = "us-west-2b"
  }
  tags = {
    Name           = "regional-manual-nat"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.regional-manual-igw]
}

resource "aws_route" "route_regional-manual-rt-private_to_regional-manual-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.regional-manual-nat.id
  route_table_id         = aws_route_table.regional-manual-rt-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_regional-manual-rt-public_to_regional-manual-igw_ipv4" {
  gateway_id             = aws_internet_gateway.regional-manual-igw.id
  route_table_id         = aws_route_table.regional-manual-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "regional-manual-rt-private" {
  vpc_id = aws_vpc.regional-manual-vpc.id
  tags = {
    Name           = "regional-manual-rt-private"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "regional-manual-rt-public" {
  vpc_id = aws_vpc.regional-manual-vpc.id
  tags = {
    Name           = "regional-manual-rt-public"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_regional_manual_private_a_regional_manual_rt_private" {
  route_table_id = aws_route_table.regional-manual-rt-private.id
  subnet_id      = aws_subnet.regional-manual-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_manual_private_b_regional_manual_rt_private" {
  route_table_id = aws_route_table.regional-manual-rt-private.id
  subnet_id      = aws_subnet.regional-manual-private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_manual_public_a_regional_manual_rt_public" {
  route_table_id = aws_route_table.regional-manual-rt-public.id
  subnet_id      = aws_subnet.regional-manual-public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_regional_manual_public_b_regional_manual_rt_public" {
  route_table_id = aws_route_table.regional-manual-rt-public.id
  subnet_id      = aws_subnet.regional-manual-public-b.id
}

resource "aws_eip" "regional-manual-eip-az-a" {
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "regional-manual-eip-az-a"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eip" "regional-manual-eip-az-a-extra" {
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "regional-manual-eip-az-a-extra"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eip" "regional-manual-eip-az-b" {
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "regional-manual-eip-az-b"
    State          = "regional-manual-state"
    Struct8Creator = "rmay struct"
  }
}


