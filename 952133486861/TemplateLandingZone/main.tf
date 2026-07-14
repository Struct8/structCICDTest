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
    key            = "952133486861/TemplateLandingZone/main.tfstate"
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

resource "aws_vpc" "LandingZone" {
  cidr_block                        = "10.0.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "LandingZone"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Private-a" {
  vpc_id                            = aws_vpc.LandingZone.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.10.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Private-a"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Private-b" {
  vpc_id                            = aws_vpc.LandingZone.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.11.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Private-b"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Public-a" {
  vpc_id                            = aws_vpc.LandingZone.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "Public-a"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "Public-b" {
  vpc_id                            = aws_vpc.LandingZone.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "Public-b"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id                            = aws_vpc.LandingZone.id
  tags                              = {
    Name = "IGW"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_nat_gateway" "NAT" {
  allocation_id                     = aws_eip.eip_nat.id
  subnet_id                         = aws_subnet.Public-a.id
  availability_mode                 = "zonal"
  tags                              = {
    Name = "NAT"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_route" "route_RT-Private_to_NAT_ipv4" {
  nat_gateway_id                    = aws_nat_gateway.NAT.id
  route_table_id                    = aws_route_table.RT-Private.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_RT-Public_to_IGW_ipv4" {
  gateway_id                        = aws_internet_gateway.IGW.id
  route_table_id                    = aws_route_table.RT-Public.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT-Private" {
  vpc_id                            = aws_vpc.LandingZone.id
  tags                              = {
    Name = "RT-Private"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table" "RT-Public" {
  vpc_id                            = aws_vpc.LandingZone.id
  tags                              = {
    Name = "RT-Public"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Private_a_RT_Private" {
  route_table_id                    = aws_route_table.RT-Private.id
  subnet_id                         = aws_subnet.Private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_Private_b_RT_Private" {
  route_table_id                    = aws_route_table.RT-Private.id
  subnet_id                         = aws_subnet.Private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_Public_a_RT_Public" {
  route_table_id                    = aws_route_table.RT-Public.id
  subnet_id                         = aws_subnet.Public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_Public_b_RT_Public" {
  route_table_id                    = aws_route_table.RT-Public.id
  subnet_id                         = aws_subnet.Public-b.id
}

resource "aws_eip" "eip_nat" {
  domain                            = "vpc"
  tags                              = {
    Name = "eip_nat"
    State = "TemplateLandingZone"
    Struct8User = "rmay struct"
  }
}


