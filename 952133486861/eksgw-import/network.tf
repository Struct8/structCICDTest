resource "aws_vpc" "eksgw-vpc" {
  cidr_block           = "10.78.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "eksgw-vpc"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "eksgw-public-us-west-2a" {
  vpc_id                              = aws_vpc.eksgw-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.78.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                  = "eksgw-public-us-west-2a"
    Project                               = "eks-gw-lab"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/eksgw-cluster" = "shared"
    State                                 = "eksgw-import"
    Struct8Creator                        = "rmay struct"
  }
}

resource "aws_subnet" "eksgw-public-us-west-2b" {
  vpc_id                              = aws_vpc.eksgw-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.78.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                  = "eksgw-public-us-west-2b"
    Project                               = "eks-gw-lab"
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/eksgw-cluster" = "shared"
    State                                 = "eksgw-import"
    Struct8Creator                        = "rmay struct"
  }
}

resource "aws_internet_gateway" "eksgw-igw" {
  vpc_id = aws_vpc.eksgw-vpc.id
  tags = {
    Name           = "eksgw-igw"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_eksgw-public-rt_to_eksgw-igw_ipv4" {
  gateway_id             = aws_internet_gateway.eksgw-igw.id
  route_table_id         = aws_route_table.eksgw-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "eksgw-public-rt" {
  vpc_id = aws_vpc.eksgw-vpc.id
  tags = {
    Name           = "eksgw-public-rt"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_eksgw_public_us_west_2a_eksgw_public_rt" {
  route_table_id = aws_route_table.eksgw-public-rt.id
  subnet_id      = aws_subnet.eksgw-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_eksgw_public_us_west_2b_eksgw_public_rt" {
  route_table_id = aws_route_table.eksgw-public-rt.id
  subnet_id      = aws_subnet.eksgw-public-us-west-2b.id
}

resource "aws_security_group" "eksgw-alb-sg" {
  name        = "eksgw-alb-sg"
  vpc_id      = aws_vpc.eksgw-vpc.id
  description = "eksgw ALB: HTTP from the internet"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "eksgw-alb-sg"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_eksgw_alb_sg_egress_all_protocols" {
  security_group_id = aws_security_group.eksgw-alb-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eksgw_alb_sg_ingress_tcp_80" {
  security_group_id = aws_security_group.eksgw-alb-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_lb" "eksgw-alb" {
  name                             = "eksgw-alb"
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.eksgw-alb-sg.id]
  subnets                          = [aws_subnet.eksgw-public-us-west-2a.id, aws_subnet.eksgw-public-us-west-2b.id]
  tags = {
    Name           = "eksgw-alb"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "eksgw-http" {
  load_balancer_arn                    = aws_lb.eksgw-alb.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    target_group_arn = aws_lb_target_group.eksgw-tg.arn
    type             = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.eksgw-tg.arn
        weight = 1
      }
    }
  }
  tags = {
    Name           = "eksgw-http"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "eksgw-tg" {
  name                              = "eksgw-tg"
  vpc_id                            = aws_vpc.eksgw-vpc.id
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  target_type                       = "ip"
  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
  tags = {
    Name           = "eksgw-tg"
    Project        = "eks-gw-lab"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
  target_group_health {
    dns_failover {
      minimum_healthy_targets_count      = "1"
      minimum_healthy_targets_percentage = "off"
    }
    unhealthy_state_routing {
      minimum_healthy_targets_count      = 1
      minimum_healthy_targets_percentage = "off"
    }
  }
}
