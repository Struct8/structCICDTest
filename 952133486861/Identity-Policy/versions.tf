terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/Identity-Policy/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}
