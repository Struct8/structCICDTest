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

resource "aws_subnet" "Subnet3" {
  vpc_id                            = aws_vpc.VPC1.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.10.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Subnet3"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group" "db_instance_rdsdb1_group" {
  name                              = "db_instance_rdsdb1_group"
  vpc_id                            = aws_vpc.VPC1.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "db_instance_rdsdb1_group"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_db_instance_rdsdb1_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.db_instance_rdsdb1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}




### CATEGORY: STORAGE ###

resource "aws_db_instance" "rdsdb1" {
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_rdsdb1.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.Subnet2.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  identifier                        = "rdsdb1"
  instance_class                    = "db.t3.micro"
  max_allocated_storage             = 100
  password                          = "teste98098080"
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = "admin"
  vpc_security_group_ids            = [aws_security_group.db_instance_rdsdb1_group.id]
  tags                              = {
    Name = "rdsdb1"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}

resource "aws_db_subnet_group" "subnet_group_rdsdb1" {
  name                              = "rdsdb1-subnet-group"
  subnet_ids                        = [aws_subnet.Subnet2.id, aws_subnet.Subnet3.id]
  tags                              = {
    Name = "subnet_group_rdsdb1"
    State = "State3snsteste"
    Struct8User = "rmay struct"
  }
}


