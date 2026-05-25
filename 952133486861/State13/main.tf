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

resource "aws_subnet" "Subnet13" {
  vpc_id                            = aws_vpc.VPC4.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.3.1.0/24"
  map_public_ip_on_launch           = false
  tags                              = {
    Name = "Subnet13"
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

resource "aws_security_group" "db_instance_rdsdb2_group" {
  name                              = "db_instance_rdsdb2_group"
  vpc_id                            = aws_vpc.VPC4.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "db_instance_rdsdb2_group"
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

resource "aws_security_group_rule" "rule_autoscaling_group_ASG1_group_to_db_instance_rdsdb2_group_tcp_3306" {
  security_group_id                 = aws_security_group.db_instance_rdsdb2_group.id
  source_security_group_id          = aws_security_group.autoscaling_group_ASG1_group.id
  description                       = "Allow from autoscaling_group_ASG1_group (tcp:3306-3306)"
  from_port                         = 3306
  protocol                          = "tcp"
  to_port                           = 3306
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_db_instance_rdsdb2_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.db_instance_rdsdb2_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}




### CATEGORY: STORAGE ###

resource "aws_db_instance" "rdsdb2" {
  db_name                           = "test"
  db_subnet_group_name              = aws_db_subnet_group.subnet_group_rdsdb2.name
  allocated_storage                 = 20
  availability_zone                 = aws_subnet.Subnet13.availability_zone
  backup_retention_period           = 0
  copy_tags_to_snapshot             = true
  delete_automated_backups          = false
  engine                            = "mysql"
  engine_version                    = "8.0"
  identifier                        = "rdsdb2"
  instance_class                    = "db.t3.micro"
  manage_master_user_password       = true
  max_allocated_storage             = 100
  skip_final_snapshot               = true
  storage_encrypted                 = true
  storage_type                      = "gp3"
  upgrade_storage_config            = false
  username                          = "admin"
  vpc_security_group_ids            = [aws_security_group.db_instance_rdsdb2_group.id]
  tags                              = {
    Name = "rdsdb2"
    State = "State13"
    Struct8User = "Ricardo"
  }
}

resource "aws_db_subnet_group" "subnet_group_rdsdb2" {
  name                              = "rdsdb2-subnet-group"
  subnet_ids                        = [aws_subnet.Subnet13.id, aws_subnet.Subnet10.id]
  tags                              = {
    Name = "subnet_group_rdsdb2"
    State = "State13"
    Struct8User = "Ricardo"
  }
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
AWS_DB_INSTANCE_ENDPOINT_0="${aws_db_instance.rdsdb2.endpoint}"
AWS_DB_INSTANCE_DB_NAME_0="${aws_db_instance.rdsdb2.db_name}"
AWS_DB_INSTANCE_SECRET_ARN_0="${one(aws_db_instance.database6.master_user_secret[*].secret_arn)}"
AWS_DB_INSTANCE_USER_NAME_0="${one(aws_db_instance.rdsdb2.master_user_secret[*].secret_arn)}:username::"
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


