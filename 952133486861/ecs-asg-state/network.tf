resource "aws_vpc" "ecs-asg-vpc" {
  cidr_block       = "10.6.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name           = "ecs-asg-vpc"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "ecs-asg-private-a" {
  vpc_id                  = aws_vpc.ecs-asg-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.6.1.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "ecs-asg-private-a"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "ecs-asg-private-b" {
  vpc_id                  = aws_vpc.ecs-asg-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.6.3.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "ecs-asg-private-b"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "ecs-asg-public-a" {
  vpc_id                  = aws_vpc.ecs-asg-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.6.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "ecs-asg-public-a"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "ecs-asg-public-b" {
  vpc_id                  = aws_vpc.ecs-asg-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.6.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "ecs-asg-public-b"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "ecs-asg-igw" {
  vpc_id = aws_vpc.ecs-asg-vpc.id
  tags = {
    Name           = "ecs-asg-igw"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_ecs-asg-rtb-private_to_ecs-asg-nat-instance_ipv4" {
  network_interface_id   = aws_instance.ecs-asg-nat-instance.primary_network_interface_id
  route_table_id         = aws_route_table.ecs-asg-rtb-private.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_ecs-asg-rtb-public_to_ecs-asg-igw_ipv4" {
  gateway_id             = aws_internet_gateway.ecs-asg-igw.id
  route_table_id         = aws_route_table.ecs-asg-rtb-public.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "ecs-asg-rtb-private" {
  vpc_id = aws_vpc.ecs-asg-vpc.id
  tags = {
    Name           = "ecs-asg-rtb-private"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "ecs-asg-rtb-public" {
  vpc_id = aws_vpc.ecs-asg-vpc.id
  tags = {
    Name           = "ecs-asg-rtb-public"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_ecs_asg_private_a_ecs_asg_rtb_private" {
  route_table_id = aws_route_table.ecs-asg-rtb-private.id
  subnet_id      = aws_subnet.ecs-asg-private-a.id
}

resource "aws_route_table_association" "aws_route_table_association_ecs_asg_private_b_ecs_asg_rtb_private" {
  route_table_id = aws_route_table.ecs-asg-rtb-private.id
  subnet_id      = aws_subnet.ecs-asg-private-b.id
}

resource "aws_route_table_association" "aws_route_table_association_ecs_asg_public_a_ecs_asg_rtb_public" {
  route_table_id = aws_route_table.ecs-asg-rtb-public.id
  subnet_id      = aws_subnet.ecs-asg-public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_ecs_asg_public_b_ecs_asg_rtb_public" {
  route_table_id = aws_route_table.ecs-asg-rtb-public.id
  subnet_id      = aws_subnet.ecs-asg-public-b.id
}

resource "aws_security_group" "autoscaling_group_ecs-asg-nodes_group" {
  name                   = "autoscaling_group_ecs-asg-nodes_group"
  vpc_id                 = aws_vpc.ecs-asg-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "autoscaling_group_ecs-asg-nodes_group"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_ecs-asg-k6_group" {
  name                   = "instance_ecs-asg-k6_group"
  vpc_id                 = aws_vpc.ecs-asg-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_ecs-asg-k6_group"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "instance_ecs-asg-nat-instance_group" {
  name                   = "instance_ecs-asg-nat-instance_group"
  vpc_id                 = aws_vpc.ecs-asg-vpc.id
  description            = "NAT instance: allow all traffic from inside the VPC, egress anywhere"
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_ecs-asg-nat-instance_group"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "lb_ecs-asg-alb_group" {
  name                   = "lb_ecs-asg-alb_group"
  vpc_id                 = aws_vpc.ecs-asg-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "lb_ecs-asg-alb_group"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_autoscaling_group_ecs_asg_nodes_group_egress_all_protocols" {
  security_group_id = aws_security_group.autoscaling_group_ecs-asg-nodes_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_autoscaling_group_ecs_asg_nodes_group_ingress_tcp_80" {
  security_group_id = aws_security_group.autoscaling_group_ecs-asg-nodes_group.id
  cidr_blocks       = ["10.6.0.0/16"]
  description       = "HTTP interno da VPC (teste via NAT)"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_ecs_asg_k6_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_ecs-asg-k6_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_ecs_asg_k6_group_ingress_tcp_5665" {
  security_group_id = aws_security_group.instance_ecs-asg-k6_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "k6 live dashboard (teaching lab)"
  from_port         = 5665
  protocol          = "tcp"
  to_port           = 5665
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_ecs_asg_k6_group_ingress_tcp_80" {
  security_group_id = aws_security_group.instance_ecs-asg-k6_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "k6 control panel (teaching lab)"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_instance_ecs_asg_nat_instance_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_ecs-asg-nat-instance_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_instance_ecs_asg_nat_instance_group_ingress_all_protocols" {
  security_group_id = aws_security_group.instance_ecs-asg-nat-instance_group.id
  cidr_blocks       = ["10.6.0.0/16"]
  description       = "All traffic from within VPC2 (private subnets route through here)"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_ecs_asg_alb_group_egress_all_protocols" {
  security_group_id = aws_security_group.lb_ecs-asg-alb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_ecs_asg_alb_group_ingress_tcp_80" {
  security_group_id = aws_security_group.lb_ecs-asg-alb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP from VPC (k6 load generator via public path)"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_ecs_asg_alb_group_to_autoscaling_group_ecs_asg_nodes_group_tcp_32768_65535" {
  security_group_id        = aws_security_group.autoscaling_group_ecs-asg-nodes_group.id
  source_security_group_id = aws_security_group.lb_ecs-asg-alb_group.id
  description              = "ALB para tasks ECS (bridge dynamic ports)"
  from_port                = 32768
  protocol                 = "tcp"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_lb" "ecs-asg-alb" {
  name               = "ecs-asg-alb"
  idle_timeout       = 60
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_ecs-asg-alb_group.id]
  subnets            = [aws_subnet.ecs-asg-public-a.id, aws_subnet.ecs-asg-public-b.id]
  tags = {
    Name           = "ecs-asg-alb"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_listener" "ecs-asg-listener" {
  load_balancer_arn                    = aws_lb.ecs-asg-alb.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.ecs-asg-tg-hub.arn
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.ecs-asg-tg-hub.arn
      }
    }
  }
  tags = {
    Name           = "ecs-asg-listener"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_lb_target_group" "ecs-asg-tg-hub" {
  name                          = "ecs-asg-tg-hub"
  vpc_id                        = aws_vpc.ecs-asg-vpc.id
  deregistration_delay          = "300"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  port                          = 8080
  protocol                      = "HTTP"
  target_type                   = "instance"
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
  tags = {
    Name           = "ecs-asg-tg-hub"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}
