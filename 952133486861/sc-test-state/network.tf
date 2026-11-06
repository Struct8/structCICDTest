resource "aws_vpc" "service-connect-test" {
  assign_generated_ipv6_cidr_block     = true
  cidr_block                           = "10.5.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  instance_tenancy                     = "default"
  ipv6_cidr_block_network_border_group = "us-west-2"
  tags = {
    Name           = "service-connect-test"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "sc-test-nat-public" {
  vpc_id                              = aws_vpc.service-connect-test.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.5.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "sc-test-nat-public"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "sc-test-private-a" {
  vpc_id                              = aws_vpc.service-connect-test.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.5.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "sc-test-private-a"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "sc-test-igw" {
  vpc_id = aws_vpc.service-connect-test.id
  tags = {
    Name           = "sc-test-igw"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-private3_to_sc-test-nat_ipv4" {
  network_interface_id   = aws_instance.sc-test-nat.primary_network_interface_id
  route_table_id         = aws_route_table.rt-private3.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-public3_to_sc-test-igw_ipv4" {
  gateway_id             = aws_internet_gateway.sc-test-igw.id
  route_table_id         = aws_route_table.rt-public3.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-private3" {
  vpc_id = aws_vpc.service-connect-test.id
  tags = {
    Name           = "rt-private3"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-public3" {
  vpc_id = aws_vpc.service-connect-test.id
  tags = {
    Name           = "rt-public3"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_sc_test_nat_public_rt_public3" {
  route_table_id = aws_route_table.rt-public3.id
  subnet_id      = aws_subnet.sc-test-nat-public.id
}

resource "aws_route_table_association" "aws_route_table_association_sc_test_private_a_rt_private3" {
  route_table_id = aws_route_table.rt-private3.id
  subnet_id      = aws_subnet.sc-test-private-a.id
}

resource "aws_security_group" "ecs_task_definition_sc-client_group" {
  name                   = "ecs_task_definition_sc-client_group"
  vpc_id                 = aws_vpc.service-connect-test.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "ecs_task_definition_sc-client_group"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "ecs_task_definition_sc-server_group" {
  name                   = "ecs_task_definition_sc-server_group"
  vpc_id                 = aws_vpc.service-connect-test.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "ecs_task_definition_sc-server_group"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_sc-test-nat_group" {
  name                   = "instance_sc-test-nat_group"
  vpc_id                 = aws_vpc.service-connect-test.id
  description            = "NAT instance SG: accepts all traffic from the VPC CIDR to forward/masquerade to the internet; egress open."
  revoke_rules_on_delete = false
}

resource "aws_security_group_rule" "rule_ecs_task_definition_sc_client_group_egress_all_protocols" {
  security_group_id = aws_security_group.ecs_task_definition_sc-client_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_sc_client_group_to_ecs_task_definition_sc_server_group_tcp_80" {
  security_group_id        = aws_security_group.ecs_task_definition_sc-server_group.id
  source_security_group_id = aws_security_group.ecs_task_definition_sc-client_group.id
  description              = "Allow from ecs_task_definition_sc-client_group (tcp:80-80)"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_ecs_task_definition_sc_server_group_egress_all_protocols" {
  security_group_id = aws_security_group.ecs_task_definition_sc-server_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_sc_test_nat_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_sc-test-nat_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_sc_test_nat_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_sc-test-nat_group.id
  cidr_blocks       = ["10.5.0.0/16"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_service_discovery_http_namespace" "sc-test-ns" {
  name        = "sc-test-ns"
  description = "HTTP namespace for Service Connect -- the directory where the server advertises itself and the client looks it up. Attached to the cluster. Required for the 'server' name to resolve inside the tasks."
  tags = {
    Name           = "sc-test-ns"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}
