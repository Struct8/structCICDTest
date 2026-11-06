resource "aws_vpc" "VPC3" {
  cidr_block       = "10.3.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "VPC3"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "hub-public-a" {
  vpc_id                  = aws_vpc.VPC3.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.3.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "hub-public-a"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "hub-igw" {
  vpc_id = aws_vpc.VPC3.id
  tags = {
    Name           = "hub-igw"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_hub-rt-public_to_hub-igw_ipv4" {
  gateway_id             = aws_internet_gateway.hub-igw.id
  route_table_id         = aws_route_table.hub-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "hub-rt-public" {
  vpc_id = aws_vpc.VPC3.id
  tags = {
    Name           = "hub-rt-public"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_hub_public_a_hub_rt_public" {
  route_table_id = aws_route_table.hub-rt-public.id
  subnet_id      = aws_subnet.hub-public-a.id
}

resource "aws_security_group" "ecs_task_definition_hub_group" {
  name                   = "ecs_task_definition_hub_group"
  vpc_id                 = aws_vpc.VPC3.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "ecs_task_definition_hub_group"
    State          = "hub-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_ecs_task_definition_hub_group_egress_all_protocols" {
  security_group_id = aws_security_group.ecs_task_definition_hub_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}
