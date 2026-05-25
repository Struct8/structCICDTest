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
    key            = "952133486861/State13/main.tfstate"
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

resource "aws_iam_instance_profile" "profile_ASG1" {
  name                              = "profile_ASG1"
  role                              = aws_iam_role.role_asg_ASG1.name
  tags                              = {
    Name = "profile_ASG1"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_role" "role_asg_ASG1" {
  name                              = "role_asg_ASG1"
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
    Name = "role_asg_ASG1"
    State = "State13"
    Struct8User = "Ricardo"
  }
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPC4" {
  cidr_block                        = "10.3.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPC4"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Subnet10" {
  vpc_id                            = aws_vpc.VPC4.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.3.0.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Subnet10"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group" "autoscaling_group_ASG1_group" {
  name                              = "autoscaling_group_ASG1_group"
  vpc_id                            = aws_vpc.VPC4.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "autoscaling_group_ASG1_group"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_autoscaling_group_ASG1_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.autoscaling_group_ASG1_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Template2" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template2" {
  image_id                          = data.aws_ami.AMI_Data_Source_Template2.id
  name                              = "Template2"
  ebs_optimized                     = true
  instance_type                     = "t3.micro"
  update_default_version            = true
  user_data                         = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="ASG1"
REGION="${data.aws_region.current.name}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---


EOFUData
)
  vpc_security_group_ids            = [aws_security_group.autoscaling_group_ASG1_group.id]
  block_device_mappings {
    device_name                     = "/dev/xvda"
    no_device                       = false
    ebs {
      delete_on_termination         = true
      encrypted                     = true
      iops                          = 3000
      throughput                    = 125
      volume_size                   = 8
      volume_type                   = "gp3"
    }
  }
  iam_instance_profile {
    name                            = aws_iam_instance_profile.profile_ASG1.name
  }
  tags                              = {
    Name = "Template2"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_autoscaling_group" "ASG1" {
  name                              = "ASG1"
  capacity_rebalance                = false
  default_cooldown                  = 300
  default_instance_warmup           = 0
  desired_capacity                  = 1
  force_delete                      = false
  force_delete_warm_pool            = false
  health_check_grace_period         = 300
  health_check_type                 = "EC2"
  ignore_failed_scaling_activities  = false
  max_instance_lifetime             = 0
  max_size                          = 1
  metrics_granularity               = "1Minute"
  min_elb_capacity                  = 0
  min_size                          = 1
  protect_from_scale_in             = false
  termination_policies              = ["Default"]
  vpc_zone_identifier               = [aws_subnet.Subnet10.id]
  wait_for_elb_capacity             = 0
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template2.id
  }
  tag {
    key                             = "Name"
    propagate_at_launch             = true
    value                           = "ASG1"
  }
  tag {
    key                             = "State"
    propagate_at_launch             = true
    value                           = "State13"
  }
  tag {
    key                             = "Struct8User"
    propagate_at_launch             = true
    value                           = "Ricardo"
  }
}


