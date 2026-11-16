terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/k8simp13-k8s/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}
