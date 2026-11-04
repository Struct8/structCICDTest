# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"

  ignore_tags {
    key_prefixes = ["elasticbeanstalk:"]
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
