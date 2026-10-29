terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/sfn_e_import/main.tfstate"
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

### EXTERNAL REFERENCES ###

data "aws_lambda_function" "order-console" {
  function_name = "order-console"
}




### CATEGORY: COMPUTE ###

resource "aws_lambda_function_url" "order-console" {
  function_name      = data.aws_lambda_function.order-console.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console_to_order-console" {
  function_name          = data.aws_lambda_function.order-console.function_name
  statement_id           = "perm_aws_lambda_function_url_order-console-url_to_order-consolead7f6e9527e86115ffb969333e"
  principal              = "*"
  action                 = "lambda:InvokeFunctionUrl"
  function_url_auth_type = "NONE"
  depends_on             = [aws_lambda_function_url.order-console]
}

resource "aws_lambda_permission" "perm_aws_lambda_function_url_order-console_to_order-console_invoke" {
  function_name            = data.aws_lambda_function.order-console.function_name
  statement_id             = "perm_aws_lambda_function_url_order-console-url_to_order-console_invokec749ed41c68ba62fcceba166fb"
  principal                = "*"
  action                   = "lambda:InvokeFunction"
  invoked_via_function_url = true
  depends_on               = [aws_lambda_function_url.order-console, aws_lambda_permission.perm_aws_lambda_function_url_order-console_to_order-console]
}


