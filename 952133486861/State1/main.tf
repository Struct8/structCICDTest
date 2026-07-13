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

### CATEGORY: IAM ###

resource "aws_iam_instance_profile" "Environment_profile" {
  name                              = "Environment_profile"
  role                              = aws_iam_role.Environment_role.name
  tags                              = {
    Name = "Environment_profile"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

data "aws_iam_policy_document" "elastic_beanstalk_environment_Environment_Environment_role_st_State1_doc" {
  statement {
    sid                             = "AllowSQSActions"
    effect                          = "Allow"
    actions                         = ["sqs:DeleteMessage", "sqs:GetQueueAttributes", "sqs:ReceiveMessage", "sqs:SendMessage"]
    resources                       = ["${aws_sqs_queue.Queue.arn}"]
  }
}

resource "aws_iam_policy" "elastic_beanstalk_environment_Environment_Environment_role_st_State1" {
  name                              = "elastic_beanstalk_environment_Environment_Environment_role_st_State1"
  description                       = "Access Policy for Environment (Role: Environment_role)"
  policy                            = data.aws_iam_policy_document.elastic_beanstalk_environment_Environment_Environment_role_st_State1_doc.json
}

resource "aws_iam_role" "Environment_role" {
  name                              = "Environment_role"
  assume_role_policy                = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}]}"
  force_detach_policies             = false
  max_session_duration              = 3600
  path                              = "/"
  tags                              = {
    Name = "Environment_role"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_iam_role" "role_eb_Application" {
  name                              = "role_eb_Application"
  assume_role_policy                = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      }
    }
  ]
})
  tags                              = {
    Name = "role_eb_Application"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkMulticontainerDocker_to_Environment_attach" {
  policy_arn                        = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
  role                              = aws_iam_role.Environment_role.name
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWebTier_to_Environment_attach" {
  policy_arn                        = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
  role                              = aws_iam_role.Environment_role.name
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWorkerTier_to_Environment_attach" {
  policy_arn                        = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
  role                              = aws_iam_role.Environment_role.name
}

resource "aws_iam_role_policy_attachment" "elastic_beanstalk_environment_Environment_Environment_role_st_State1_attach" {
  policy_arn                        = aws_iam_policy.elastic_beanstalk_environment_Environment_Environment_role_st_State1.arn
  role                              = aws_iam_role.Environment_role.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "main" {
  cidr_block                        = "10.0.0.0/16"
  enable_dns_hostnames              = true
  enable_dns_support                = true
  instance_tenancy                  = "default"
  tags                              = {
    Name = "main"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.11.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "private_1"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.12.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "private_2"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.0.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "public_1"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                            = aws_vpc.main.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.0.2.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    Name = "public_2"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                            = aws_vpc.main.id
  tags                              = {
    Name = "igw"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_nat_gateway" "NAT" {
  vpc_id                            = aws_vpc.main.id
  availability_mode                 = "regional"
  connectivity_type                 = "public"
  availability_zone_address {
    allocation_ids                  = [aws_eip.eip_nat_0.id]
    availability_zone               = aws_subnet.public_1.availability_zone
  }
  availability_zone_address {
    allocation_ids                  = [aws_eip.eip_nat_1.id]
    availability_zone               = aws_subnet.public_2.availability_zone
  }
  tags                              = {
    Name = "NAT"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_route" "route_public_to_igw_ipv4" {
  gateway_id                        = aws_internet_gateway.igw.id
  route_table_id                    = aws_route_table.public.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route" "route_public_to_igw_ipv6" {
  gateway_id                        = aws_internet_gateway.igw.id
  route_table_id                    = aws_route_table.public.id
  destination_ipv6_cidr_block       = "::/0"
}

resource "aws_route_table" "private" {
  vpc_id                            = aws_vpc.main.id
  tags                              = {
    Name = "private"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table" "public" {
  vpc_id                            = aws_vpc.main.id
  tags                              = {
    Name = "public"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_private_1_private" {
  route_table_id                    = aws_route_table.private.id
  subnet_id                         = aws_subnet.private_1.id
}

resource "aws_route_table_association" "aws_route_table_association_private_2_private" {
  route_table_id                    = aws_route_table.private.id
  subnet_id                         = aws_subnet.private_2.id
}

resource "aws_route_table_association" "aws_route_table_association_public_1_public" {
  route_table_id                    = aws_route_table.public.id
  subnet_id                         = aws_subnet.public_1.id
}

resource "aws_route_table_association" "aws_route_table_association_public_2_public" {
  route_table_id                    = aws_route_table.public.id
  subnet_id                         = aws_subnet.public_2.id
}

resource "aws_security_group" "elastic_beanstalk_environment_Environment_group" {
  name                              = "elastic_beanstalk_environment_Environment_group"
  vpc_id                            = aws_vpc.main.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "elastic_beanstalk_environment_Environment_group"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group" "lb_alb_ALB_group" {
  name                              = "lb_alb_ALB_group"
  vpc_id                            = aws_vpc.main.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "lb_alb_ALB_group"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_elastic_beanstalk_environment_Environment_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.elastic_beanstalk_environment_Environment_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALB_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.lb_alb_ALB_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_eip" "eip_nat_0" {
  domain                            = "vpc"
  tags                              = {
    Name = "eip_nat_0"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_eip" "eip_nat_1" {
  domain                            = "vpc"
  tags                              = {
    Name = "eip_nat_1"
    State = "State1"
    Struct8User = "rmay struct"
  }
}




### CATEGORY: INTEGRATION ###

resource "aws_sqs_queue" "Queue" {
  name                              = "Queue"
  delay_seconds                     = 0
  fifo_queue                        = false
  kms_data_key_reuse_period_seconds = 300
  max_message_size                  = 262144
  message_retention_seconds         = 345600
  receive_wait_time_seconds         = 0
  sqs_managed_sse_enabled           = true
  visibility_timeout_seconds        = 30
  tags                              = {
    Name = "Queue"
    State = "State1"
    Struct8User = "rmay struct"
  }
}




### CATEGORY: MISC ###

resource "aws_elastic_beanstalk_application" "Application" {
  name                              = "Application"
  tags                              = {
    Name = "Application"
    State = "State1"
    Struct8User = "rmay struct"
  }
}

resource "aws_elastic_beanstalk_environment" "Environment" {
  name                              = "Environment"
  solution_stack_name               = "64bit Amazon Linux 2023 v4.1.0 running Node.js 20"
  application                       = aws_elastic_beanstalk_application.Application.name
  wait_for_ready_timeout            = "20m"
  setting {
    name                            = "VPCId"
    namespace                       = "aws:ec2:vpc"
    value                           = aws_vpc.main.id
  }
  setting {
    name                            = "Subnets"
    namespace                       = "aws:ec2:vpc"
    value                           = "${aws_subnet.private_2.id},${aws_subnet.private_1.id}"
  }
  setting {
    name                            = "ELBSubnets"
    namespace                       = "aws:ec2:vpc"
    value                           = "${aws_subnet.public_1.id},${aws_subnet.public_2.id}"
  }
  setting {
    name                            = "IamInstanceProfile"
    namespace                       = "aws:autoscaling:launchconfiguration"
    value                           = aws_iam_instance_profile.Environment_profile.name
  }
  tags                              = {
    Name = "Environment"
    State = "State1"
    Struct8User = "rmay struct"
  }
}


