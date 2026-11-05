data "local_file" "UserData_k6-load-generator" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-k6-load-generator/v1/user_data/k6-bootstrap.sh"
}

data "aws_ami" "AMI_Data_Source_k6-load-generator" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_instance" "k6-load-generator" {
  subnet_id                   = aws_subnet.public-k6.id
  ami                         = data.aws_ami.AMI_Data_Source_k6-load-generator.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.k6-load-generator_profile.name
  instance_type               = "t4g.nano"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
AUTOSTART="on"
STARTUP_DELAY="60"
DURATION="20m"
VUS="30"
METHOD="POST"
MS="250"
BOOT_GEN="4"
NAME="k6-load-generator"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
AWS_LB_DNSNAME_0="${aws_lb.alb-hub.dns_name}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_k6-load-generator.content}
EOFUData
)
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.instance_k6-load-generator_group.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    Struct8Debug   = "0WMToJ4cZSqnBZhOjNzSl"
    Name           = "k6-load-generator"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_nat-a" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_nat-a" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "nat-a" {
  subnet_id                   = aws_subnet.public-a.id
  ami                         = data.aws_ami.AMI_Data_Source_nat-a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-a_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="nat-a"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_nat-a.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_nat-a_group.id]
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "nat-a"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_hub-lt" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-hub-docker/v1/user_data/hub-docker.sh"
}

data "aws_ami" "AMI_Data_Source_hub-lt" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_launch_template" "hub-lt" {
  image_id               = data.aws_ami.AMI_Data_Source_hub-lt.id
  name                   = "hub-lt"
  description            = "ASG Launch Template. user_data (hub-docker.sh) installs Docker then builds and runs the Hub arm64 image with HUB_LOADTEST on. Boot build ~5min so the ASG grace period is high. Mixed instances policy: all override types must be arm64 to match this AMI."
  instance_type          = "t4g.nano"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
HUB_LOADTEST="on"
HUB_PORT="8080"
BOOT_GEN="3"
NAME="hub-asg-mixed"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_hub-lt.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_hub-asg-mixed_group.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 8
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.hub-asg-mixed_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name           = "hub-asg-mixed"
      State          = "loadtest-asg-mixed"
      Struct8Creator = "rmay struct"
    }
  }
  tags = {
    Name           = "hub-lt"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "hub-asg-mixed" {
  name                      = "hub-asg-mixed"
  capacity_rebalance        = true
  default_instance_warmup   = 420
  desired_capacity          = 1
  enabled_metrics           = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  health_check_grace_period = 600
  health_check_type         = "ELB"
  max_instance_lifetime     = 604800
  max_size                  = 3
  metrics_granularity       = "1Minute"
  min_size                  = 1
  target_group_arns         = [aws_lb_target_group.tg-hub.arn]
  termination_policies      = ["OldestLaunchTemplate", "OldestInstance", "Default"]
  vpc_zone_identifier       = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  instance_maintenance_policy {
    max_healthy_percentage = 110
    min_healthy_percentage = 90
  }
  instance_refresh {
    strategy = "Rolling"
  }
  lifecycle {
    ignore_changes = [desired_capacity]
  }
  mixed_instances_policy {
    instances_distribution {
      on_demand_allocation_strategy            = "prioritized"
      on_demand_base_capacity                  = 1
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }
    launch_template {
      launch_template_specification {
        version            = aws_launch_template.hub-lt.latest_version
        launch_template_id = aws_launch_template.hub-lt.id
      }
      override {
        instance_type     = "t4g.nano"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t4g.micro"
        weighted_capacity = "1"
      }
      override {
        instance_type     = "t4g.small"
        weighted_capacity = "2"
      }
      override {
        instance_type     = "m6g.medium"
        weighted_capacity = "2"
      }
    }
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "hub-asg-mixed"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "loadtest-asg-mixed"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}

resource "aws_autoscaling_policy" "cpu-scale" {
  autoscaling_group_name    = aws_autoscaling_group.hub-asg-mixed.name
  name                      = "cpu-scale"
  enabled                   = true
  estimated_instance_warmup = 300
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    disable_scale_in = false
    target_value     = 50
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

resource "aws_autoscaling_policy" "cpu-spike-step" {
  autoscaling_group_name    = aws_autoscaling_group.hub-asg-mixed.name
  name                      = "cpu-spike-step"
  adjustment_type           = "ChangeInCapacity"
  enabled                   = true
  estimated_instance_warmup = 300
  metric_aggregation_type   = "Average"
  policy_type               = "StepScaling"
  step_adjustment {
    metric_interval_lower_bound = "0"
    scaling_adjustment          = 2
  }
}

resource "aws_autoscaling_policy" "requests-scale" {
  autoscaling_group_name    = aws_autoscaling_group.hub-asg-mixed.name
  name                      = "requests-scale"
  enabled                   = true
  estimated_instance_warmup = 300
  policy_type               = "TargetTrackingScaling"
  target_tracking_configuration {
    disable_scale_in = false
    target_value     = 1000
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_lb.alb-hub.arn_suffix}/${aws_lb_target_group.tg-hub.arn_suffix}"
    }
  }
  depends_on = [aws_lb_listener.listener-http]
}
