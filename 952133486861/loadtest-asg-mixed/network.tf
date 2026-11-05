resource "aws_vpc" "ltmixed-vpc" {
  cidr_block           = "10.60.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "ltmixed-vpc"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id                  = aws_vpc.ltmixed-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.60.11.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "private-a"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id                  = aws_vpc.ltmixed-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.60.0.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "private-b"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.ltmixed-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.60.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public-a"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.ltmixed-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.60.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public-b"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "public-k6" {
  vpc_id                  = aws_vpc.ltmixed-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.60.3.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "public-k6"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw-k6" {
  vpc_id = aws_vpc.ltmixed-vpc.id
  tags = {
    Name           = "igw-k6"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-private1_to_nat-a_ipv4" {
  network_interface_id   = aws_instance.nat-a.primary_network_interface_id
  route_table_id         = aws_route_table.rt-private1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_rt-public1_to_igw-k6_ipv4" {
  gateway_id             = aws_internet_gateway.igw-k6.id
  route_table_id         = aws_route_table.rt-public1.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "rt-private1" {
  vpc_id = aws_vpc.ltmixed-vpc.id
  tags = {
    Name           = "rt-private1"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-public1" {
  vpc_id = aws_vpc.ltmixed-vpc.id
  tags = {
    Name           = "rt-public1"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_a_rt_private1" {
  route_table_id = aws_route_table.rt-private1.id
  subnet_id      = aws_subnet.private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_private_b_rt_private1" {
  route_table_id = aws_route_table.rt-private1.id
  subnet_id      = aws_subnet.private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_public_a_rt_public1" {
  route_table_id = aws_route_table.rt-public1.id
  subnet_id      = aws_subnet.public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_public_b_rt_public1" {
  route_table_id = aws_route_table.rt-public1.id
  subnet_id      = aws_subnet.public-b.id
}

resource "aws_route_table_association" "aws_route_table_association_public_k6_rt_public1" {
  route_table_id = aws_route_table.rt-public1.id
  subnet_id      = aws_subnet.public-k6.id
}

resource "aws_security_group" "autoscaling_group_hub-asg-mixed_group" {
  name                   = "autoscaling_group_hub-asg-mixed_group"
  vpc_id                 = aws_vpc.ltmixed-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "autoscaling_group_hub-asg-mixed_group"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_k6-load-generator_group" {
  name                   = "instance_k6-load-generator_group"
  vpc_id                 = aws_vpc.ltmixed-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_k6-load-generator_group"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_nat-a_group" {
  name                   = "instance_nat-a_group"
  vpc_id                 = aws_vpc.ltmixed-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_nat-a_group"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "lb_alb-hub_group" {
  name                   = "lb_alb-hub_group"
  vpc_id                 = aws_vpc.ltmixed-vpc.id
  revoke_rules_on_delete = false
}

resource "aws_security_group_rule" "rule_autoscaling_group_hub_asg_mixed_group_egress_all_protocols" {
  security_group_id = aws_security_group.autoscaling_group_hub-asg-mixed_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_hub_asg_mixed_group_ingress_tcp_8080" {
  security_group_id = aws_security_group.autoscaling_group_hub-asg-mixed_group.id
  cidr_blocks       = ["10.60.0.0/16"]
  description       = "Hub HTTP on 8080 from within the VPC (the ALB target group forwards load here)"
  from_port         = 8080
  protocol          = "tcp"
  to_port           = 8080
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_k6_load_generator_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_k6-load-generator_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_k6_load_generator_group_ingress_tcp_5665" {
  security_group_id = aws_security_group.instance_k6-load-generator_group.id
  cidr_blocks       = ["10.60.0.0/16"]
  description       = "k6 web dashboard, forwarded from the NAT instance"
  from_port         = 5665
  protocol          = "tcp"
  to_port           = 5665
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_k6_load_generator_group_to_lb_alb_hub_group_tcp_80" {
  security_group_id        = aws_security_group.lb_alb-hub_group.id
  source_security_group_id = aws_security_group.instance_k6-load-generator_group.id
  description              = "HTTP load test traffic from k6 to the ALB"
  from_port                = 80
  protocol                 = "tcp"
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_a_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-a_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_nat_a_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_nat-a_group.id
  cidr_blocks       = ["10.60.0.0/16"]
  description       = "NAT: all traffic from the VPC to be routed out"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_nat_a_group_ingress_tcp_5665" {
  security_group_id = aws_security_group.instance_nat-a_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "k6 web dashboard from the internet"
  from_port         = 5665
  protocol          = "tcp"
  to_port           = 5665
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_hub_group_egress_all_protocols" {
  security_group_id = aws_security_group.lb_alb-hub_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_hub_group_ingress_tcp_5665" {
  security_group_id = aws_security_group.lb_alb-hub_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "k6 dashboard via ALB (public, ephemeral test env)"
  from_port         = 5665
  protocol          = "tcp"
  to_port           = 5665
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_hub_group_ingress_tcp_80" {
  security_group_id = aws_security_group.lb_alb-hub_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "k6 load traffic to Hub via ALB (public: k6 reaches the ALB by its public IP)"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_hub_group_to_autoscaling_group_hub_asg_mixed_group_tcp_8080" {
  security_group_id        = aws_security_group.autoscaling_group_hub-asg-mixed_group.id
  source_security_group_id = aws_security_group.lb_alb-hub_group.id
  description              = "Hub HTTP from the ALB target group"
  from_port                = 8080
  protocol                 = "tcp"
  to_port                  = 8080
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_hub_group_to_instance_k6_load_generator_group_tcp_5665" {
  security_group_id        = aws_security_group.instance_k6-load-generator_group.id
  source_security_group_id = aws_security_group.lb_alb-hub_group.id
  description              = "k6 web dashboard from the ALB"
  from_port                = 5665
  protocol                 = "tcp"
  to_port                  = 5665
  type                     = "ingress"
}

resource "aws_lb" "alb-hub" {
  name                             = "alb-hub"
  enable_cross_zone_load_balancing = true
  enable_http2                     = false
  idle_timeout                     = 120
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.lb_alb-hub_group.id]
  subnets                          = [aws_subnet.public-a.id, aws_subnet.public-b.id]
  tags = {
    Name           = "alb-hub"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "listener-dashboard" {
  load_balancer_arn                    = aws_lb.alb-hub.arn
  port                                 = 5665
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.tg-k6-dashboard.arn
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-k6-dashboard.arn
      }
    }
  }
  tags = {
    Name           = "listener-dashboard"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "listener-http" {
  load_balancer_arn                    = aws_lb.alb-hub.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.tg-hub.arn
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.tg-hub.arn
      }
    }
  }
  tags = {
    Name           = "listener-http"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "tg-hub" {
  name                          = "tg-hub"
  vpc_id                        = aws_vpc.ltmixed-vpc.id
  deregistration_delay          = "30"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "least_outstanding_requests"
  port                          = 8080
  protocol                      = "HTTP"
  target_type                   = "instance"
  health_check {
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name           = "tg-hub"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "tg-k6-dashboard" {
  name                          = "tg-k6-dashboard"
  vpc_id                        = aws_vpc.ltmixed-vpc.id
  deregistration_delay          = "300"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  port                          = 5665
  protocol                      = "HTTP"
  target_type                   = "instance"
  health_check {
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200-399"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  tags = {
    Name           = "tg-k6-dashboard"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group_attachment" "attach_k6-load-generator_to_tg-k6-dashboard" {
  target_id        = aws_instance.k6-load-generator.id
  port             = 5665
  target_group_arn = aws_lb_target_group.tg-k6-dashboard.arn
}
