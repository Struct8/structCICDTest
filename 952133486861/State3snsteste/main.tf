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


