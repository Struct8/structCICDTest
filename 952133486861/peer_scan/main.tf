terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/peer_scan/main.tfstate"
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

resource "aws_vpc_peering_connection" "Peering-Monitoring-to-Monitored" {
  peer_vpc_id = "vpc-008fee4c9dc714d5f"
  vpc_id      = "vpc-0855088a39dd0e1e2"
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  tags = {
    Name           = "Peering-Monitoring-to-Monitored"
    State          = "State-Peering"
    Struct8Creator = "rmay struct"
  }
}


