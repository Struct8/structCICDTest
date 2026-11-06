resource "aws_vpc" "vpc-b" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "vpc-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "dynamodb-endpoint-b_DynamoDB" {
  service_name      = "com.amazonaws.us-west-2.dynamodb"
  vpc_id            = aws_vpc.vpc-b.id
  policy            = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}],\"Version\":\"2008-10-17\"}"
  route_table_ids   = [aws_route_table.rt-vpc-b-private.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    DifName        = "dynamodb-endpoint-b_DynamoDB"
    Name           = "dynamodb-endpoint-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "vpc-b-private" {
  vpc_id                              = aws_vpc.vpc-b.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.1.0.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "vpc-b-private"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "vpc-b-public" {
  vpc_id                              = aws_vpc.vpc-b.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.1.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "vpc-b-public"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-b" {
  vpc_id = aws_vpc.vpc-b.id
  tags = {
    Name           = "igw-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-vpc-b-private_to_nat-b_ipv4" {
  network_interface_id   = aws_instance.nat-b.primary_network_interface_id
  route_table_id         = aws_route_table.rt-vpc-b-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-vpc-b-public_to_igw-b_ipv4" {
  gateway_id             = aws_internet_gateway.igw-b.id
  route_table_id         = aws_route_table.rt-vpc-b-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-vpc-b-private" {
  vpc_id = aws_vpc.vpc-b.id
  tags = {
    Name           = "rt-vpc-b-private"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-vpc-b-public" {
  vpc_id = aws_vpc.vpc-b.id
  tags = {
    Name           = "rt-vpc-b-public"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_vpc_b_private_rt_vpc_b_private" {
  route_table_id = aws_route_table.rt-vpc-b-private.id
  subnet_id      = aws_subnet.vpc-b-private.id
}

resource "aws_route_table_association" "aws_route_table_association_vpc_b_public_rt_vpc_b_public" {
  route_table_id = aws_route_table.rt-vpc-b-public.id
  subnet_id      = aws_subnet.vpc-b-public.id
}

resource "aws_security_group" "autoscaling_group_traffic-gen-asg_group" {
  name                   = "autoscaling_group_traffic-gen-asg_group"
  vpc_id                 = aws_vpc.vpc-b.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "autoscaling_group_traffic-gen-asg_group"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat-b_group" {
  name                   = "instance_nat-b_group"
  vpc_id                 = aws_vpc.vpc-b.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat-b_group"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_egress_all_protocols" {
  security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_to_instance_nat_b_group_tcp_443" {
  security_group_id        = aws_security_group.instance_nat-b_group.id
  source_security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  description              = "HTTPS that nat-b forwards to the internet for traffic-gen-asg"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_to_instance_traffic_gen_private_group_icmp_8_0" {
  security_group_id        = data.aws_security_group.instance_traffic-gen-private_group.id
  source_security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  description              = "Ping (ICMP echo request) from traffic-gen-asg"
  from_port                = 8
  protocol                 = "icmp"
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_to_instance_traffic_gen_private_group_tcp_22" {
  security_group_id        = data.aws_security_group.instance_traffic-gen-private_group.id
  source_security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  description              = "SSH from traffic-gen-asg"
  from_port                = 22
  protocol                 = "tcp"
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_to_instance_traffic_gen_private_group_tcp_80" {
  security_group_id        = data.aws_security_group.instance_traffic-gen-private_group.id
  source_security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  description              = "HTTP from traffic-gen-asg"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_traffic_gen_asg_group_to_instance_traffic_gen_private_group_udp_53" {
  security_group_id        = data.aws_security_group.instance_traffic-gen-private_group.id
  source_security_group_id = aws_security_group.autoscaling_group_traffic-gen-asg_group.id
  description              = "DNS from traffic-gen-asg"
  from_port                = 53
  protocol                 = "udp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_b_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-b_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_flow_log" "flowlog-vpc-b" {
  vpc_id                   = aws_vpc.vpc-b.id
  log_destination          = data.aws_s3_bucket.flowlogs-bucket.arn
  log_destination_type     = "s3"
  log_format               = "$${version} $${vpc-id} $${subnet-id} $${interface-id} $${instance-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${flow-direction} $${traffic-path} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${interface-type}"
  max_aggregation_interval = 60
  traffic_type             = "ALL"
  tags = {
    Name           = "flowlog-vpc-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}
