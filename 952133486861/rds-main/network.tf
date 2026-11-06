resource "aws_subnet" "demo-mysql-private-a" {
  vpc_id                  = data.aws_vpc.demo-mysql-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.7.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "demo-mysql-private-a"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "demo-mysql-private-b" {
  vpc_id                  = data.aws_vpc.demo-mysql-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.7.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "demo-mysql-private-b"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "db_instance_demo-mysql_group" {
  name                   = "db_instance_demo-mysql_group"
  vpc_id                 = data.aws_vpc.demo-mysql-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_instance_demo-mysql_group"
    State          = "rds-main"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_db_instance_demo_mysql_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_instance_demo-mysql_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_db_instance_demo_mysql_group_ingress_tcp_3306" {
  security_group_id = aws_security_group.db_instance_demo-mysql_group.id
  cidr_blocks       = ["10.7.0.0/16"]
  description       = "MySQL from inside the VPC"
  from_port         = 3306
  protocol          = "tcp"
  to_port           = 3306
  type              = "ingress"
}
