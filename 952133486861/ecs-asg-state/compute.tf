data "local_file" "UserData_ecs-asg-k6" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-k6-load-generator/v2/user_data/k6-bootstrap.sh"
}

data "aws_ami" "AMI_Data_Source_ecs-asg-k6" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_instance" "ecs-asg-k6" {
  subnet_id                   = aws_subnet.ecs-asg-public-a.id
  ami                         = data.aws_ami.AMI_Data_Source_ecs-asg-k6.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs-asg-k6_profile.name
  instance_type               = "t4g.nano"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
K6_PANEL="on"
K6_PANEL_REF="main"
TARGET_URL="http://${aws_lb.ecs-asg-alb.dns_name}/loadtest?ms=80"
NAME="ecs-asg-k6"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_ecs-asg-k6.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_ecs-asg-k6_group.id]
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
    Name           = "ecs-asg-k6"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_ecs-asg-nat-instance" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_ecs-asg-nat-instance" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "ecs-asg-nat-instance" {
  subnet_id                   = aws_subnet.ecs-asg-public-b.id
  ami                         = data.aws_ami.AMI_Data_Source_ecs-asg-nat-instance.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ecs-asg-nat-instance_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_ecs-asg-nat-instance.content}
EOFUData
)
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.instance_ecs-asg-nat-instance_group.id]
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type             = "one-time"
    }
  }
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
    Name           = "ecs-asg-nat-instance"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_ami" "AMI_Data_Source_ecs-asg-lt" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "ecs-asg-lt" {
  image_id               = data.aws_ami.AMI_Data_Source_ecs-asg-lt.id
  name                   = "ecs-asg-lt"
  description            = "ECS container instances for the ASG (t3.nano, x86_64 -- matches the x86_64 Hub image). user_data joins the ecs-asg-cluster. In private subnets, so they reach ECR/ECS via the NAT."
  instance_type          = "t3.nano"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
ECS_CLUSTER="${aws_ecs_cluster.ecs-asg-cluster.name}"
NAME="ecs-asg-nodes"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

# --- BEGIN STRUCT8 ECS BOOTSTRAP ---
mkdir -p /etc/ecs
source /etc/struct8_env
echo "ECS_CLUSTER=$ECS_CLUSTER" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config
# --- END STRUCT8 ECS BOOTSTRAP ---

echo "ECS_CLUSTER=ecs-asg-cluster" >> /etc/ecs/ecs.config
EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_ecs-asg-nodes_group.id]
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      throughput            = 125
      volume_size           = 30
      volume_type           = "gp3"
    }
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-asg-nodes_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      AmazonECSManaged = true
      Name             = "ecs-asg-nodes"
      State            = "ecs-asg-state"
      Struct8Creator   = "rmay struct"
    }
  }
  tags = {
    Name           = "ecs-asg-lt"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "ecs-asg-nodes" {
  name                  = "ecs-asg-nodes"
  default_cooldown      = 30
  desired_capacity      = 1
  enabled_metrics       = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  health_check_type     = "EC2"
  max_instance_lifetime = 0
  max_size              = 3
  metrics_granularity   = "1Minute"
  min_size              = 1
  termination_policies  = ["Default"]
  vpc_zone_identifier   = [aws_subnet.ecs-asg-private-a.id, aws_subnet.ecs-asg-private-b.id]
  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
    preferences {
      instance_warmup        = 60
      min_healthy_percentage = 0
    }
  }
  launch_template {
    version = aws_launch_template.ecs-asg-lt.latest_version
    id      = aws_launch_template.ecs-asg-lt.id
  }
  lifecycle {
    ignore_changes = [desired_capacity]
  }
  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "ecs-asg-nodes"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "ecs-asg-state"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}

resource "aws_appautoscaling_policy" "ecs-asg-hub-cpu" {
  name               = "ecs-asg-hub-cpu"
  resource_id        = aws_appautoscaling_target.ecs-asg-hub-scale.resource_id
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = aws_appautoscaling_target.ecs-asg-hub-scale.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-asg-hub-scale.service_namespace
  target_tracking_scaling_policy_configuration {
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 30
    target_value       = 50
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_appautoscaling_target" "ecs-asg-hub-scale" {
  resource_id        = "service/${aws_ecs_cluster.ecs-asg-cluster.name}/${aws_ecs_service.ecs-asg-hub_service.name}"
  max_capacity       = 12
  min_capacity       = 1
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    Name           = "ecs-asg-hub-scale"
    State          = "ecs-asg-state"
    Struct8Creator = "rmay struct"
  }
}
