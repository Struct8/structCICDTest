terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/aurora-params-state/main.tfstate"
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

### CATEGORY: DATABASE ###

resource "aws_db_parameter_group" "demo-aurora-instance-params" {
  description  = "Managed by Struct8"
  family       = "aurora-postgresql16"
  name_prefix  = "demo-aurora-instance-params"
  skip_destroy = false
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name           = "demo-aurora-instance-params"
    State          = "aurora-params-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_rds_cluster_parameter_group" "demo-aurora-cluster-params" {
  description = "Managed by Struct8"
  family      = "aurora-postgresql16"
  name_prefix = "demo-aurora-cluster-params"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name           = "demo-aurora-cluster-params"
    State          = "aurora-params-state"
    Struct8Creator = "rmay struct"
  }
}


