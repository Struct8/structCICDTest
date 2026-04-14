terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/StateSNS/main.tfstate"
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

### CATEGORY: INTEGRATION ###

resource "aws_sns_topic" "Topic1" {
  name                              = "Topic1"
  tags                              = {
    "Name" = "Topic1"
    "State" = "StateSNS"
    "CloudmanUser" = "Ricardo"
  }
}


