resource "aws_vpc" "eksimp-vpc" {
  cidr_block           = "10.77.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "eksimp-vpc"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-private-us-west-2a" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.77.11.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                   = "eksimp-private-us-west-2a"
    Project                                = "eks-import-lab"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/eksimp-cluster" = "shared"
    State                                  = "eksimp-import"
    Struct8Creator                         = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-private-us-west-2b" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.77.12.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                   = "eksimp-private-us-west-2b"
    Project                                = "eks-import-lab"
    "kubernetes.io/role/internal-elb"      = "1"
    "kubernetes.io/cluster/eksimp-cluster" = "shared"
    State                                  = "eksimp-import"
    Struct8Creator                         = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-public-us-west-2a" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.77.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                     = "eksimp-public-us-west-2a"
    Project                  = "eks-import-lab"
    "kubernetes.io/role/elb" = "1"
    State                    = "eksimp-import"
    Struct8Creator           = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-public-us-west-2b" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.77.2.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                     = "eksimp-public-us-west-2b"
    Project                  = "eks-import-lab"
    "kubernetes.io/role/elb" = "1"
    State                    = "eksimp-import"
    Struct8Creator           = "rmay struct"
  }
}

resource "aws_internet_gateway" "eksimp-igw" {
  vpc_id = aws_vpc.eksimp-vpc.id
  tags = {
    Name           = "eksimp-igw"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "eksimp-nat" {
  allocation_id     = aws_eip.eksimp-nat-eip.id
  subnet_id         = aws_subnet.eksimp-public-us-west-2a.id
  availability_mode = "zonal"
  private_ip        = "10.77.1.5"
  tags = {
    Name           = "eksimp-nat"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.eksimp-igw]
}

resource "aws_route" "route_eksimp-private-rt_to_eksimp-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.eksimp-nat.id
  route_table_id         = aws_route_table.eksimp-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_eksimp-public-rt_to_eksimp-igw_ipv4" {
  gateway_id             = aws_internet_gateway.eksimp-igw.id
  route_table_id         = aws_route_table.eksimp-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "eksimp-private-rt" {
  vpc_id = aws_vpc.eksimp-vpc.id
  tags = {
    Name           = "eksimp-private-rt"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "eksimp-public-rt" {
  vpc_id = aws_vpc.eksimp-vpc.id
  tags = {
    Name           = "eksimp-public-rt"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_private_us_west_2a_eksimp_private_rt" {
  route_table_id = aws_route_table.eksimp-private-rt.id
  subnet_id      = aws_subnet.eksimp-private-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_private_us_west_2b_eksimp_private_rt" {
  route_table_id = aws_route_table.eksimp-private-rt.id
  subnet_id      = aws_subnet.eksimp-private-us-west-2b.id
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_public_us_west_2a_eksimp_public_rt" {
  route_table_id = aws_route_table.eksimp-public-rt.id
  subnet_id      = aws_subnet.eksimp-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_public_us_west_2b_eksimp_public_rt" {
  route_table_id = aws_route_table.eksimp-public-rt.id
  subnet_id      = aws_subnet.eksimp-public-us-west-2b.id
}

resource "aws_security_group" "eksimp-alb-sg" {
  name        = "eksimp-alb-sg"
  vpc_id      = aws_vpc.eksimp-vpc.id
  description = "eksimp ALB: HTTP from the internet"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "eksimp-alb-sg"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_eksimp_alb_sg_egress_all_protocols" {
  security_group_id = aws_security_group.eksimp-alb-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eksimp_alb_sg_ingress_tcp_80" {
  security_group_id = aws_security_group.eksimp-alb-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_eip" "eksimp-nat-eip" {
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "eksimp-nat-eip"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb" "eksimp-alb" {
  name                             = "eksimp-alb"
  enable_cross_zone_load_balancing = true
  idle_timeout                     = 60
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.eksimp-alb-sg.id]
  subnets                          = [aws_subnet.eksimp-public-us-west-2a.id, aws_subnet.eksimp-public-us-west-2b.id]
  tags = {
    Name           = "eksimp-alb"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "eksimp-http" {
  load_balancer_arn                    = aws_lb.eksimp-alb.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    target_group_arn = aws_lb_target_group.eksimp-tg.arn
    type             = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.eksimp-tg.arn
        weight = 1
      }
    }
  }
  tags = {
    Name           = "eksimp-http"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "eksimp-tg" {
  name                              = "eksimp-tg"
  vpc_id                            = aws_vpc.eksimp-vpc.id
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  load_balancing_anomaly_mitigation = "off"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  port                              = 30080
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  target_type                       = "instance"
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
    Name           = "eksimp-tg"
    Project        = "eks-import-lab"
    State          = "eksimp-import"
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
