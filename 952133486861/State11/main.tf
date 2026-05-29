terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

### SYSTEM DATA SOURCES ###

data "aws_route53_zone" "Zone2" {
  name                              = "cloudman.pro"
}




### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "profile_ASG3" {
  name                              = "profile_ASG3"
  role                              = aws_iam_role.role_asg_ASG3.name
  tags                              = {
    Name = "profile_ASG3"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_instance_profile" "profile_Instance1" {
  name                              = "profile_Instance1"
  role                              = aws_iam_role.role_ec2_Instance1.name
  tags                              = {
    Name = "profile_Instance1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_role" "role_asg_ASG3" {
  name                              = "role_asg_ASG3"
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
    Name = "role_asg_ASG3"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_role" "role_ec2_Instance1" {
  name                              = "role_ec2_Instance1"
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
    Name = "role_ec2_Instance1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_acm_certificate" "albx" {
  domain_name                       = "albx.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  subject_alternative_names         = ["*.albx.cloudman.pro"]
  validation_method                 = "DNS"
  lifecycle {
    create_before_destroy           = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    Name = "albx"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_acm_certificate_validation" "Validation_albx" {
  certificate_arn                   = aws_acm_certificate.albx.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_albx_albx_cloudman_pro : record.fqdn]
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
  map_public_ip_on_launch           = true
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
  map_public_ip_on_launch           = true
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

resource "aws_route53_record" "Route53_Record_albx_albx_cloudman_pro" {
  for_each                          = {
    for dvo in aws_acm_certificate.albx.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "albx.cloudman.pro"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.Zone2.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route53_record" "alias_a_aws_lb_Xalb_ALB1_albx_cloudman_pro" {
  name                              = "albx.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Zone2.zone_id
  type                              = "A"
  alias {
    name                            = aws_lb.ALB1.dns_name
    zone_id                         = aws_lb.ALB1.zone_id
    evaluate_target_health          = true
  }
}

resource "aws_route53_record" "alias_a_aws_lb_Xalb_ALB1_wildcard_albx_cloudman_pro" {
  name                              = "*.albx.cloudman.pro"
  zone_id                           = data.aws_route53_zone.Zone2.zone_id
  type                              = "A"
  alias {
    name                            = aws_lb.ALB1.dns_name
    zone_id                         = aws_lb.ALB1.zone_id
    evaluate_target_health          = true
  }
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

resource "aws_security_group" "autoscaling_group_ASG3_group" {
  name                              = "autoscaling_group_ASG3_group"
  vpc_id                            = aws_vpc.VPC3.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "autoscaling_group_ASG3_group"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group" "instance_Instance1_group" {
  name                              = "instance_Instance1_group"
  vpc_id                            = aws_vpc.VPC3.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "instance_Instance1_group"
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

resource "aws_security_group_rule" "rule_autoscaling_group_ASG3_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.autoscaling_group_ASG3_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_instance_Instance1_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.instance_Instance1_group.id
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

resource "aws_security_group_rule" "rule_lb_alb_ALB1_group_ingress_tcp_443" {
  security_group_id                 = aws_security_group.lb_alb_ALB1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 443
  protocol                          = "tcp"
  to_port                           = 443
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB1_group_to_autoscaling_group_ASG3_group_tcp_80" {
  security_group_id                 = aws_security_group.autoscaling_group_ASG3_group.id
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
  subnet_count                      = 1
  subnets                           = [aws_subnet.Public-a.id, aws_subnet.Public-b.id]
  tags                              = {
    Name = "ALB1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_lb_listener" "Listener2" {
  certificate_arn                   = aws_acm_certificate.albx.arn
  load_balancer_arn                 = aws_lb.ALB1.arn
  port                              = 443
  protocol                          = "HTTPS"
  routing_http_response_server_enabled = true
  default_action {
    order                           = 1
    type                            = "fixed-response"
    fixed_response {
      content_type                  = "text/plain"
      message_body                  = "bom dia!!!"
      status_code                   = "200"
    }
  }
  tags                              = {
    Name = "Listener2"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

resource "aws_lb_listener_rule" "Rule" {
  action {
    order                           = 1
    target_group_arn                = aws_lb_target_group.TG-Grafana.arn
    type                            = "forward"
    forward {
      target_group {
        arn                         = aws_lb_target_group.TG-Grafana.arn
      }
    }
  }
  condition {
    host_header {
      values                        = ["grafana.albx.cloudman.pro"]
    }
  }
  listener_arn                      = aws_lb_listener.Listener2.arn
  priority                          = 1
  tags                              = {
    Name = "Rule"
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

data "aws_ami" "AMI_Data_Source_Instance1" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "Instance1" {
  subnet_id                         = aws_subnet.Grafana-b.id
  ami                               = data.aws_ami.AMI_Data_Source_Instance1.id
  associate_public_ip_address       = true
  iam_instance_profile              = aws_iam_instance_profile.profile_Instance1.name
  instance_type                     = "t3.micro"
  user_data_base64                  = base64encode(<<-EOFUData
#!/bin/bash


EOFUData
)
  user_data_replace_on_change       = false
  vpc_security_group_ids            = [aws_security_group.instance_Instance1_group.id]
  root_block_device {
    encrypted                       = true
    iops                            = 3000
    throughput                      = 125
    volume_size                     = 8
    volume_type                     = "gp3"
  }
  tags                              = {
    Name = "Instance1"
    State = "State11"
    Struct8User = "Ricardo"
  }
}

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
  instance_type                     = "t3.medium"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="ASG3"
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
  vpc_security_group_ids            = [aws_security_group.autoscaling_group_ASG3_group.id]
  block_device_mappings {
    ebs {
      delete_on_termination         = true
      iops                          = 3000
      throughput                    = 125
      volume_size                   = 800
      volume_type                   = "gp3"
    }
  }
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_ASG3.name
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

resource "aws_autoscaling_group" "ASG3" {
  name                              = "ASG3"
  capacity_rebalance                = false
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 1
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "ELB"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 1
  metrics_granularity               = "1Minute"
  min_elb_capacity                  = 0
  min_size                          = 1
  protect_from_scale_in             = false
  target_group_arns                 = [aws_lb_target_group.TG-Grafana.arn]
  termination_policies              = ["Default"]
  vpc_zone_identifier               = [aws_subnet.Grafana-a.id, aws_subnet.Grafana-b.id]
  wait_for_elb_capacity             = 0
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Grafana.id
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "ASG3"
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


