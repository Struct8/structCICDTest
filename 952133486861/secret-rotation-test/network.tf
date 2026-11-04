resource "aws_vpc" "rotation-vpc" {
  cidr_block           = "10.77.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "rotation-vpc"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "rotation-a" {
  vpc_id                  = aws_vpc.rotation-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.77.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "rotation-a"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "rotation-b" {
  vpc_id                  = aws_vpc.rotation-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.77.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "rotation-b"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "db_instance_rotation-db-ignored_group" {
  name                   = "db_instance_rotation-db-ignored_group"
  vpc_id                 = aws_vpc.rotation-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_instance_rotation-db-ignored_group"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "db_instance_rotation-db-plain_group" {
  name                   = "db_instance_rotation-db-plain_group"
  vpc_id                 = aws_vpc.rotation-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_instance_rotation-db-plain_group"
    State          = "secret-rotation-test"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_db_instance_rotation_db_ignored_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_instance_rotation-db-ignored_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_db_instance_rotation_db_plain_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_instance_rotation-db-plain_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}
