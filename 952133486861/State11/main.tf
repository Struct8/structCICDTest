terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/State11/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_Grafana" {
  name                              = "profile_Grafana"
  role                              = aws_iam_role.role_asg_Grafana.name
  tags                              = {
    Name = "profile_Grafana"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_role" "role_asg_Grafana" {
  name                              = "role_asg_Grafana"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    Name = "role_asg_Grafana"
    State = "State11"
    Struct8User = "Ricardo"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC3" {
  cidr_block                        = "10.5.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC3"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Grafana-a" {
  vpc_id                            = aws_vpc.VPC3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.5.0.0/22"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Grafana-a"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Grafana-b" {
  vpc_id                            = aws_vpc.VPC3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.5.4.0/22"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Grafana-b"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Public-a" {
  vpc_id                            = aws_vpc.VPC3.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.5.8.0/22"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "Public-a"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Public-b" {
  vpc_id                            = aws_vpc.VPC3.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.5.12.0/22"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "Public-b"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_internet_gateway" "IGW1" {
  vpc_id                            = aws_vpc.VPC3.id
  tags                              = {
    Name = "IGW1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_nat_gateway" "NAT1" {
  vpc_id                            = aws_vpc.VPC3.id
  availability_mode                 = "regional"
  tags                              = {
    Name = "NAT1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_route" "aws_route_RT2_IGW1" {
  gateway_id                        = aws_internet_gateway.IGW1.id
  route_table_id                    = aws_route_table.RT2.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "aws_route_RT3_NAT1" {
  nat_gateway_id                    = aws_nat_gateway.NAT1.id
  route_table_id                    = aws_route_table.RT3.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RT2" {
  vpc_id                            = aws_vpc.VPC3.id
  tags                              = {
    Name = "RT2"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_route_table" "RT3" {
  vpc_id                            = aws_vpc.VPC3.id
  tags                              = {
    Name = "RT3"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Grafana_a_RT3" {
  route_table_id                    = aws_route_table.RT3.id
  subnet_id                         = aws_subnet.Grafana-a.id
}

resource "aws_route_table_association" "aws_route_table_association_Grafana_b_RT3" {
  route_table_id                    = aws_route_table.RT3.id
  subnet_id                         = aws_subnet.Grafana-b.id
}

resource "aws_route_table_association" "aws_route_table_association_Public_a_RT2" {
  route_table_id                    = aws_route_table.RT2.id
  subnet_id                         = aws_subnet.Public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_Public_b_RT2" {
  route_table_id                    = aws_route_table.RT2.id
  subnet_id                         = aws_subnet.Public-b.id
}

resource "aws_security_group" "autoscaling_group_Grafana_group" {
  name                              = "autoscaling_group_Grafana_group"
  vpc_id                            = aws_vpc.VPC3.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "autoscaling_group_Grafana_group"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group" "lb_alb_ALB1_group" {
  name                              = "lb_alb_ALB1_group"
  vpc_id                            = aws_vpc.VPC3.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "lb_alb_ALB1_group"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_autoscaling_group_Grafana_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.autoscaling_group_Grafana_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB1_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.lb_alb_ALB1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB1_group_ingress_tcp_80" {
  security_group_id                 = aws_security_group.lb_alb_ALB1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB1_group_to_autoscaling_group_Grafana_group_tcp_80" {
  security_group_id                 = aws_security_group.autoscaling_group_Grafana_group.id
  source_security_group_id          = aws_security_group.lb_alb_ALB1_group.id
  description                       = "Allow from lb_alb_ALB1_group (tcp:80-80)"
  from_port                         = 80
  protocol                          = "tcp"
  to_port                           = 80
  type                              = "ingress"
}

resource "aws_lb" "ALB1" {
  name                              = "ALB1"
  idle_timeout                      = 60
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.lb_alb_ALB1_group.id]
  subnets                           = [aws_subnet.Public-a.id, aws_subnet.Public-b.id]
  tags                              = {
    Name = "ALB1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_lb_listener" "Listener2" {
  load_balancer_arn                 = aws_lb.ALB1.arn
  port                              = 80
  protocol                          = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG-Grafana.arn
    type                            = "forward"
    forward {
      target_group {
        arn                         = aws_lb_target_group.TG-Grafana.arn
      }
    }
  }
  tags                              = {
    Name = "Listener2"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_lb_target_group" "TG-Grafana" {
  name                              = "TG-Grafana"
  vpc_id                            = aws_vpc.VPC3.id
  connection_termination            = false
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_algorithm_type     = "round_robin"
  port                              = 80
  protocol                          = "HTTP"
  protocol_version                  = "HTTP1"
  proxy_protocol_v2                 = false
  slow_start                        = 0
  target_type                       = "instance"
  health_check {
    enabled                         = true
    healthy_threshold               = 3
    interval                        = 30
    matcher                         = "200"
    path                            = "/"
    port                            = 80
    protocol                        = "HTTP"
    timeout                         = 5
    unhealthy_threshold             = 3
  }
  tags                              = {
    Name = "TG-Grafana"
    State = "State11"
    Struct8User = "Ricardo"
  }
}




### CATEGORY: COMPUTE ###

data "local_file" "UserData_Grafana" {
  filename                          = "${path.module}/.external_modules/CloudMan/EC2/Scripts/IMDSv2.sh"
}

data "aws_ami" "AMI_Data_Source_Grafana" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Grafana" {
  image_id                          = data.aws_ami.AMI_Data_Source_Grafana.id
  name                              = "Grafana"
  ebs_optimized                     = true
  instance_type                     = "t3.nano"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="Grafana"
REGION="${data.aws_region.current.name}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_Grafana.content}
EOFUData
)
  vpc_security_group_ids            = [aws_security_group.autoscaling_group_Grafana_group.id]
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_Grafana.name
  }
  instance_market_options {
    market_type                     = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type            = "one-time"
    }
  }
  tags                              = {
    Name = "Grafana"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_autoscaling_group" "Grafana" {
  name                              = "Grafana"
  capacity_rebalance                = false
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 2
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "ELB"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 2
  metrics_granularity               = "1Minute"
  min_elb_capacity                  = 0
  min_size                          = 2
  protect_from_scale_in             = false
  target_group_arns                 = [aws_lb_target_group.TG-Grafana.arn]
  termination_policies              = ["Default"]
  vpc_zone_identifier               = [aws_subnet.Grafana-a.id, aws_subnet.Grafana-b.id]
  wait_for_elb_capacity             = 0
  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy = "lowest-price"
      spot_allocation_strategy      = "lowest-price"
      spot_instance_pools           = 1
    }
    launch_template {
      launch_template_specification {
        version                     = "$Latest"
        launch_template_id          = aws_launch_template.Grafana.id
      }
      override {
        instance_type               = "t3.micro"
      }
    }
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "Grafana"
  }
  tag {
    key                             = "State"
    propagate_at_launch             = true
    value                           = "State11"
  }
  tag {
    key                             = "Struct8User"
    propagate_at_launch             = true
    value                           = "Ricardo"
  }
}


