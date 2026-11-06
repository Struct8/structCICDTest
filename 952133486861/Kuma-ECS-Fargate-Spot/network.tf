resource "aws_vpc" "Kuma-ECS-Fargate-Spot" {
  cidr_block       = "10.3.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "Kuma-ECS-Fargate-Spot"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.Kuma-ECS-Fargate-Spot.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.3.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Kuma-ECS-Fargate-Spot.id
  tags = {
    Name           = "igw"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_public-rt_to_igw_ipv4" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.Kuma-ECS-Fargate-Spot.id
  tags = {
    Name           = "public-rt"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_public_public_rt" {
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "ecs_task_definition_kuma_group" {
  name                   = "ecs_task_definition_kuma_group"
  vpc_id                 = aws_vpc.Kuma-ECS-Fargate-Spot.id
  description            = "Uptime Kuma public access"
  revoke_rules_on_delete = false
  tags = {
    Name           = "ecs_task_definition_kuma_group"
    State          = "Kuma-ECS-Fargate-Spot"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_ecs_task_definition_kuma_group_egress_all_protocols" {
  security_group_id = aws_security_group.ecs_task_definition_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All outbound"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_kuma_group_ingress_tcp_3001" {
  security_group_id = aws_security_group.ecs_task_definition_kuma_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Kuma web UI"
  from_port         = 3001
  protocol          = "tcp"
  to_port           = 3001
  type              = "ingress"
}
