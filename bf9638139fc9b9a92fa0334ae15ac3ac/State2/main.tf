terraform {
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.21.1"
    }
  }

  backend "s3" {
    bucket  = "pro112-teste-cicd"
    key     = "bf9638139fc9b9a92fa0334ae15ac3ac/State2/main.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# --- Main Cloud Provider ---
provider "cloudflare" {}

