resource "aws_vpc" "vpc-a" {
  assign_generated_ipv6_cidr_block     = true
  cidr_block                           = "10.5.0.0/16"
  enable_dns_hostnames                 = true
  enable_dns_support                   = true
  instance_tenancy                     = "default"
  ipv6_cidr_block_network_border_group = "us-west-2"
  tags = {
    Name           = "vpc-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "dynamodb-endpoint-a_DynamoDB" {
  service_name      = "com.amazonaws.us-west-2.dynamodb"
  vpc_id            = aws_vpc.vpc-a.id
  policy            = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}],\"Version\":\"2008-10-17\"}"
  route_table_ids   = [aws_route_table.rt-vpc-a-private.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    DifName        = "dynamodb-endpoint-a_DynamoDB"
    Name           = "dynamodb-endpoint-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_vpc_endpoint" "s3-endpoint-a_S3" {
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_id            = aws_vpc.vpc-a.id
  policy            = "{\"Statement\":[{\"Action\":\"*\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Resource\":\"*\"}],\"Version\":\"2008-10-17\"}"
  route_table_ids   = [aws_route_table.rt-vpc-a-private.id]
  vpc_endpoint_type = "Gateway"
  tags = {
    DifName        = "s3-endpoint-a_S3"
    Name           = "s3-endpoint-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "vpc-a-private" {
  vpc_id                                      = aws_vpc.vpc-a.id
  availability_zone                           = "us-west-2a"
  cidr_block                                  = "10.5.1.0/24"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = false
  private_dns_hostname_type_on_launch         = "ip-name"
  tags = {
    Name           = "vpc-a-private"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "vpc-a-public" {
  vpc_id                                      = aws_vpc.vpc-a.id
  availability_zone                           = "us-west-2a"
  cidr_block                                  = "10.5.0.0/24"
  enable_resource_name_dns_a_record_on_launch = true
  map_public_ip_on_launch                     = true
  private_dns_hostname_type_on_launch         = "ip-name"
  tags = {
    Name           = "vpc-a-public"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-a" {
  vpc_id = aws_vpc.vpc-a.id
  tags = {
    Name           = "igw-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-vpc-a-private_to_nat-a_ipv4" {
  network_interface_id   = aws_instance.nat-a.primary_network_interface_id
  route_table_id         = aws_route_table.rt-vpc-a-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-vpc-a-public_to_igw-a_ipv4" {
  gateway_id             = aws_internet_gateway.igw-a.id
  route_table_id         = aws_route_table.rt-vpc-a-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-vpc-a-private" {
  vpc_id = aws_vpc.vpc-a.id
  tags = {
    Name           = "rt-vpc-a-private"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-vpc-a-public" {
  vpc_id = aws_vpc.vpc-a.id
  tags = {
    Name           = "rt-vpc-a-public"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_vpc_a_private_rt_vpc_a_private" {
  route_table_id = aws_route_table.rt-vpc-a-private.id
  subnet_id      = aws_subnet.vpc-a-private.id
}

resource "aws_route_table_association" "aws_route_table_association_vpc_a_public_rt_vpc_a_public" {
  route_table_id = aws_route_table.rt-vpc-a-public.id
  subnet_id      = aws_subnet.vpc-a-public.id
}

resource "aws_security_group" "instance_nat-a_group" {
  name                   = "instance_nat-a_group"
  vpc_id                 = aws_vpc.vpc-a.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat-a_group"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_traffic-gen-private_group" {
  name                   = "instance_traffic-gen-private_group"
  vpc_id                 = aws_vpc.vpc-a.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_traffic-gen-private_group"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_traffic-gen-public_group" {
  name                   = "instance_traffic-gen-public_group"
  vpc_id                 = aws_vpc.vpc-a.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_traffic-gen-public_group"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_instance_nat_a_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-a_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_traffic_gen_private_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_traffic-gen-private_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  ipv6_cidr_blocks  = ["::/0"]
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_traffic_gen_private_group_to_instance_nat_a_group_tcp_443" {
  security_group_id        = aws_security_group.instance_nat-a_group.id
  source_security_group_id = aws_security_group.instance_traffic-gen-private_group.id
  description              = "HTTPS that nat-a forwards to the internet for traffic-gen-private"
  from_port                = 443
  protocol                 = "tcp"
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_instance_traffic_gen_public_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_traffic-gen-public_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_traffic_gen_public_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_traffic-gen-public_group.id
  cidr_blocks       = ["10.5.0.0/16"]
  description       = "Traffic from the other instances of vpc-a, so the flow log records a reply"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_flow_log" "flowlog-vpc-a" {
  vpc_id                   = aws_vpc.vpc-a.id
  log_destination          = data.aws_s3_bucket.flowlogs-bucket.arn
  log_destination_type     = "s3"
  log_format               = "$${version} $${vpc-id} $${subnet-id} $${interface-id} $${instance-id} $${srcaddr} $${dstaddr} $${pkt-srcaddr} $${pkt-dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${flow-direction} $${traffic-path} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${interface-type}"
  max_aggregation_interval = 60
  traffic_type             = "ALL"
  tags = {
    Name           = "flowlog-vpc-a"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}
