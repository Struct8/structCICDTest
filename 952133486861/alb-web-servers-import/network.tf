resource "aws_vpc" "alb-web-servers" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "alb-web-servers"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1a"
  cidr_block                          = "10.3.1.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-subnet-a"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1b"
  cidr_block                          = "10.3.3.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-subnet-b"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-subnet-c" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1c"
  cidr_block                          = "10.3.5.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "private-subnet-c"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1a"
  cidr_block                          = "10.3.0.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "public-subnet-a"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1b"
  cidr_block                          = "10.3.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "public-subnet-b"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-subnet-c" {
  vpc_id                              = aws_vpc.alb-web-servers.id
  availability_zone                   = "us-east-1c"
  cidr_block                          = "10.3.4.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name           = "public-subnet-c"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.alb-web-servers.id
  tags = {
    Name           = "internet-gateway"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_private-route-table_to_nat-instance_ipv4" {
  network_interface_id   = aws_instance.nat-instance.primary_network_interface_id
  route_table_id         = aws_route_table.private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_public-route-table_to_internet-gateway_ipv4" {
  gateway_id             = aws_internet_gateway.internet-gateway.id
  route_table_id         = aws_route_table.public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.alb-web-servers.id
  tags = {
    Name           = "private-route-table"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.alb-web-servers.id
  tags = {
    Name           = "public-route-table"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_subnet_a_private_route_table" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-a.id
}

resource "aws_route_table_association" "aws_route_table_association_private_subnet_b_private_route_table" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-b.id
}

resource "aws_route_table_association" "aws_route_table_association_private_subnet_c_private_route_table" {
  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet-c.id
}

resource "aws_route_table_association" "aws_route_table_association_public_subnet_a_public_route_table" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-a.id
}

resource "aws_route_table_association" "aws_route_table_association_public_subnet_b_public_route_table" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-b.id
}

resource "aws_route_table_association" "aws_route_table_association_public_subnet_c_public_route_table" {
  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet-c.id
}

resource "aws_security_group" "autoscaling_group_web-server-asg_group" {
  name                   = "autoscaling_group_web-server-asg_group"
  vpc_id                 = aws_vpc.alb-web-servers.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "autoscaling_group_web-server-asg_group"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat-instance_group" {
  name                   = "instance_nat-instance_group"
  vpc_id                 = aws_vpc.alb-web-servers.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat-instance_group"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "lb_application-load-balancer_group" {
  name                   = "lb_application-load-balancer_group"
  vpc_id                 = aws_vpc.alb-web-servers.id
  description            = "Managed by Terraform"
  revoke_rules_on_delete = false
  tags = {
    Name           = "lb_application-load-balancer_group"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_autoscaling_group_web_server_asg_group_egress_all_protocols" {
  security_group_id = aws_security_group.autoscaling_group_web-server-asg_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_instance_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-instance_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_instance_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-instance_group.id
  cidr_blocks       = ["10.3.0.0/16"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_application_load_balancer_group_egress_all_protocols" {
  security_group_id = aws_security_group.lb_application-load-balancer_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_application_load_balancer_group_ingress_tcp_80" {
  security_group_id = aws_security_group.lb_application-load-balancer_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_application_load_balancer_group_to_autoscaling_group_web_server_asg_group_tcp_80" {
  security_group_id        = aws_security_group.autoscaling_group_web-server-asg_group.id
  source_security_group_id = aws_security_group.lb_application-load-balancer_group.id
  description              = "Allow from lb_application-load-balancer_group (tcp:80-80)"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_lb" "application-load-balancer" {
  name                             = "application-load-balancer"
  enable_cross_zone_load_balancing = true
  enable_http2                     = false
  idle_timeout                     = 60
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.lb_application-load-balancer_group.id]
  subnets                          = [aws_subnet.public-subnet-a.id, aws_subnet.public-subnet-b.id, aws_subnet.public-subnet-c.id]
  tags = {
    Name           = "application-load-balancer"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "http-listener" {
  load_balancer_arn                    = aws_lb.application-load-balancer.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.web-target-group.arn
    type             = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web-target-group.arn
        weight = 1
      }
    }
  }
  tags = {
    Name           = "http-listener"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "web-target-group" {
  name                               = "web-target-group"
  vpc_id                             = aws_vpc.alb-web-servers.id
  deregistration_delay               = "300"
  ip_address_type                    = "ipv4"
  lambda_multi_value_headers_enabled = false
  load_balancing_algorithm_type      = "round_robin"
  load_balancing_anomaly_mitigation  = "off"
  load_balancing_cross_zone_enabled  = "use_load_balancer_configuration"
  port                               = 80
  protocol                           = "HTTP"
  protocol_version                   = "HTTP1"
  target_type                        = "instance"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }
  tags = {
    Name           = "web-target-group"
    State          = "alb-web-servers"
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
