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

### EXTERNAL REFERENCES ###

data "aws_vpc" "VPC1" {
  filter {
    name                            = "tag:Name"
    values                          = ["VPC1"]
  }
}

data "aws_vpc" "VPC" {
  filter {
    name                            = "tag:Name"
    values                          = ["VPC"]
  }
}

data "aws_route_table" "RT" {
  filter {
    name                            = "tag:Name"
    values                          = ["RT"]
  }
}

data "aws_route_table" "RT1" {
  filter {
    name                            = "tag:Name"
    values                          = ["RT1"]
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc_peering_connection" "Peering" {
  peer_vpc_id                       = data.aws_vpc.VPC1.id
  vpc_id                            = data.aws_vpc.VPC.id
  auto_accept                       = true
  tags                              = {
    Name = "Peering"
    State = "Statepeer"
    Struct8User = "rmay struct"
  }
}

resource "aws_route" "route_RT1_to_Peering_10_10_0_0_16" {
  route_table_id                    = data.aws_route_table.RT1.id
  vpc_peering_connection_id         = aws_vpc_peering_connection.Peering.id
  destination_cidr_block            = "10.10.0.0/16"
}

resource "aws_route" "route_RT_to_Peering_10_11_0_0_16" {
  route_table_id                    = data.aws_route_table.RT.id
  vpc_peering_connection_id         = aws_vpc_peering_connection.Peering.id
  destination_cidr_block            = "10.11.0.0/16"
}


