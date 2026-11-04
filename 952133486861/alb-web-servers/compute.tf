data "local_file" "UserData_nat-instance" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/alb-web-servers/v1/user_data/nat.sh"
}

data "aws_ami" "AMI_Data_Source_nat-instance" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_instance" "nat-instance" {
  subnet_id                   = aws_subnet.public-subnet-a.id
  ami                         = data.aws_ami.AMI_Data_Source_nat-instance.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-instance_profile.name
  instance_type               = "t4g.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_nat-instance.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_nat-instance_group.id]
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
    Name           = "nat-instance"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_web-server-launch-template" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/alb-web-servers/v1/user_data/web-info-page.sh"
}

data "aws_ami" "AMI_Data_Source_web-server-launch-template" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_launch_template" "web-server-launch-template" {
  image_id               = data.aws_ami.AMI_Data_Source_web-server-launch-template.id
  name                   = "web-server-launch-template"
  description            = "Web server launch template: Graviton t4g.micro Spot, AL2023 arm64, IMDSv2 required. user_data installs Apache (with swap to avoid OOM) and serves a live IMDSv2 instance-info page at /."
  instance_type          = "t4g.micro"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
NAME="web-server-asg"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_web-server-launch-template.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_web-server-asg_group.id]
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
    name = aws_iam_instance_profile.web-server-asg_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name           = "web-server-asg"
      State          = "alb-web-servers"
      Struct8Creator = "rmay struct"
    }
  }
  tags = {
    Name           = "web-server-launch-template"
    State          = "alb-web-servers"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "web-server-asg" {
  name                      = "web-server-asg"
  desired_capacity          = 3
  health_check_grace_period = 180
  health_check_type         = "ELB"
  max_instance_lifetime     = 0
  max_size                  = 3
  metrics_granularity       = "1Minute"
  min_size                  = 3
  target_group_arns         = [aws_lb_target_group.web-target-group.arn]
  termination_policies      = ["Default"]
  vpc_zone_identifier       = [aws_subnet.private-subnet-a.id, aws_subnet.private-subnet-b.id, aws_subnet.private-subnet-c.id]
  launch_template {
    version = aws_launch_template.web-server-launch-template.latest_version
    id      = aws_launch_template.web-server-launch-template.id
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "web-server-asg"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "alb-web-servers"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}
