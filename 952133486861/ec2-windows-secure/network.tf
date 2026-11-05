resource "aws_vpc" "vpc-windows-secure" {
  cidr_block       = "10.4.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "vpc-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-windows-secure" {
  vpc_id                  = aws_vpc.vpc-windows-secure.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.4.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "private-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-windows-secure" {
  vpc_id                  = aws_vpc.vpc-windows-secure.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.4.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-windows-secure" {
  vpc_id = aws_vpc.vpc-windows-secure.id
  tags = {
    Name           = "igw-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-private-windows-secure_to_nat-windows-secure_ipv4" {
  network_interface_id   = aws_instance.nat-windows-secure.primary_network_interface_id
  route_table_id         = aws_route_table.rt-private-windows-secure.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-public-windows-secure_to_igw-windows-secure_ipv4" {
  gateway_id             = aws_internet_gateway.igw-windows-secure.id
  route_table_id         = aws_route_table.rt-public-windows-secure.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-private-windows-secure" {
  vpc_id = aws_vpc.vpc-windows-secure.id
  tags = {
    Name           = "rt-private-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-public-windows-secure" {
  vpc_id = aws_vpc.vpc-windows-secure.id
  tags = {
    Name           = "rt-public-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_windows_secure_rt_private_windows_secure" {
  route_table_id = aws_route_table.rt-private-windows-secure.id
  subnet_id      = aws_subnet.private-windows-secure.id
}

resource "aws_route_table_association" "aws_route_table_association_public_windows_secure_rt_public_windows_secure" {
  route_table_id = aws_route_table.rt-public-windows-secure.id
  subnet_id      = aws_subnet.public-windows-secure.id
}

resource "aws_security_group" "instance_nat-windows-secure_group" {
  name                   = "instance_nat-windows-secure_group"
  vpc_id                 = aws_vpc.vpc-windows-secure.id
  description            = "NAT instance of the Windows lab"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat-windows-secure_group"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_windows-secure_group" {
  name                   = "instance_windows-secure_group"
  vpc_id                 = aws_vpc.vpc-windows-secure.id
  description            = "Windows lab instance, no inbound rules"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_windows-secure_group"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_nat_windows_secure_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-windows-secure_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_windows_secure_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-windows-secure_group.id
  cidr_blocks       = ["10.4.0.0/16"]
  description       = "All from VPC"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_windows_secure_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_windows-secure_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}
