resource "aws_vpc" "codebuild-lab-vpc" {
  cidr_block       = "10.6.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "codebuild-lab-vpc"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "codebuild-lab-build-a" {
  vpc_id                  = aws_vpc.codebuild-lab-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.6.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "codebuild-lab-build-a"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "codebuild-lab-build-b" {
  vpc_id                  = aws_vpc.codebuild-lab-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.6.3.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "codebuild-lab-build-b"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "codebuild-lab-db-a" {
  vpc_id                  = aws_vpc.codebuild-lab-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.6.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "codebuild-lab-db-a"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "codebuild-lab-db-b" {
  vpc_id                  = aws_vpc.codebuild-lab-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.6.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "codebuild-lab-db-b"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "codebuild-lab-igw" {
  vpc_id = aws_vpc.codebuild-lab-vpc.id
  tags = {
    Name           = "codebuild-lab-igw"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "codebuild-lab-nat" {
  vpc_id            = aws_vpc.codebuild-lab-vpc.id
  availability_mode = "regional"
  connectivity_type = "public"
  tags = {
    Name           = "codebuild-lab-nat"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.codebuild-lab-igw]
}

resource "aws_route" "route_codebuild-lab-build-rt_to_codebuild-lab-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.codebuild-lab-nat.id
  route_table_id         = aws_route_table.codebuild-lab-build-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "codebuild-lab-build-rt" {
  vpc_id = aws_vpc.codebuild-lab-vpc.id
  tags = {
    Name           = "codebuild-lab-build-rt"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_codebuild_lab_build_a_codebuild_lab_build_rt" {
  route_table_id = aws_route_table.codebuild-lab-build-rt.id
  subnet_id      = aws_subnet.codebuild-lab-build-a.id
}

resource "aws_route_table_association" "aws_route_table_association_codebuild_lab_build_b_codebuild_lab_build_rt" {
  route_table_id = aws_route_table.codebuild-lab-build-rt.id
  subnet_id      = aws_subnet.codebuild-lab-build-b.id
}

resource "aws_security_group" "codebuild_project_codebuild-lab-integration_group" {
  name                   = "codebuild_project_codebuild-lab-integration_group"
  vpc_id                 = aws_vpc.codebuild-lab-vpc.id
  description            = "CodeBuild integration project"
  revoke_rules_on_delete = false
  tags = {
    Name           = "codebuild_project_codebuild-lab-integration_group"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "db_instance_codebuild-lab-orders-db_group" {
  name                   = "db_instance_codebuild-lab-orders-db_group"
  vpc_id                 = aws_vpc.codebuild-lab-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "db_instance_codebuild-lab-orders-db_group"
    State          = "codebuild-lab-integration"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_codebuild_project_codebuild_lab_integration_group_egress_tcp_443" {
  security_group_id = aws_security_group.codebuild_project_codebuild-lab-integration_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS to the internet through the NAT"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443
  type              = "egress"
}

resource "aws_security_group_rule" "rule_codebuild_project_codebuild_lab_integration_group_egress_tcp_5432" {
  security_group_id = aws_security_group.codebuild_project_codebuild-lab-integration_group.id
  cidr_blocks       = ["10.6.0.0/24", "10.6.1.0/24"]
  description       = "PostgreSQL to the database subnets"
  from_port         = 5432
  protocol          = "tcp"
  to_port           = 5432
  type              = "egress"
}

resource "aws_security_group_rule" "rule_codebuild_project_codebuild_lab_integration_group_to_db_instance_codebuild_lab_orders_db_group_tcp_5432" {
  security_group_id        = aws_security_group.db_instance_codebuild-lab-orders-db_group.id
  source_security_group_id = aws_security_group.codebuild_project_codebuild-lab-integration_group.id
  description              = "PostgreSQL from the integration builds"
  from_port                = 5432
  protocol                 = "tcp"
  to_port                  = 5432
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_db_instance_codebuild_lab_orders_db_group_egress_all_protocols" {
  security_group_id = aws_security_group.db_instance_codebuild-lab-orders-db_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}
