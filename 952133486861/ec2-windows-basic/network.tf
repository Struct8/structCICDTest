resource "aws_vpc" "vpc-windows-basic" {
  cidr_block           = "10.25.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "vpc-windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-windows-basic" {
  vpc_id                              = aws_vpc.vpc-windows-basic.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.25.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "public-windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-windows-basic" {
  vpc_id = aws_vpc.vpc-windows-basic.id
  tags = {
    Name           = "igw-windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-public-windows-basic_to_igw-windows-basic_ipv4" {
  gateway_id             = aws_internet_gateway.igw-windows-basic.id
  route_table_id         = aws_route_table.rt-public-windows-basic.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-public-windows-basic" {
  vpc_id = aws_vpc.vpc-windows-basic.id
  tags = {
    Name           = "rt-public-windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_public_windows_basic_rt_public_windows_basic" {
  route_table_id = aws_route_table.rt-public-windows-basic.id
  subnet_id      = aws_subnet.public-windows-basic.id
}

resource "aws_security_group" "instance_windows-basic_group" {
  name                   = "instance_windows-basic_group"
  vpc_id                 = aws_vpc.vpc-windows-basic.id
  description            = "RDP to the Windows lab instance"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_windows-basic_group"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_windows_basic_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_windows-basic_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_windows_basic_group_ingress_tcp_3389" {
  security_group_id = aws_security_group.instance_windows-basic_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "RDP. Replace 0.0.0.0/0 with your public IP/32"
  from_port         = 3389
  protocol          = "tcp"
  to_port           = 3389
  type              = "ingress"
}

resource "aws_eip" "windows-basic-eip" {
  instance             = aws_instance.windows-basic.id
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "windows-basic-eip"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.igw-windows-basic]
}
