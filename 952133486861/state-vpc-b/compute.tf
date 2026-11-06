data "local_file" "UserData_nat-b" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_nat-b" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "nat-b" {
  subnet_id                   = aws_subnet.vpc-b-public.id
  ami                         = data.aws_ami.AMI_Data_Source_nat-b.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-b_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_nat-b.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_nat-b_group.id]
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
    Name           = "nat-b"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_traffic-gen-asg-lt" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/user_data/PrivateTrafficGenerator.sh"
}

data "aws_ami" "AMI_Data_Source_traffic-gen-asg-lt" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }
}

resource "aws_launch_template" "traffic-gen-asg-lt" {
  image_id               = data.aws_ami.AMI_Data_Source_traffic-gen-asg-lt.id
  name                   = "traffic-gen-asg-lt"
  description            = "Launch template of traffic-gen-asg: t4g.nano Spot on Amazon Linux 2023, running PrivateTrafficGenerator.sh. It pings traffic-gen-private and opens SSH, HTTP and DNS conversations with it, plus one on MySQL (3306) "
  instance_type          = "t4g.nano"
  update_default_version = true
  user_data = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
PING_TARGET="10.5.1.10"
PROBE="10.5.1.10:22/tcp 10.5.1.10:80/tcp 10.5.1.10:53/udp 10.5.1.10:3306/tcp"
NAME="traffic-gen-asg"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
AWS_DYNAMODB_TABLE_NAME_0="traffic-table-b"
AWS_INSTANCE_NAME_0="nat-b"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_traffic-gen-asg-lt.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.autoscaling_group_traffic-gen-asg_group.id]
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
    name = aws_iam_instance_profile.traffic-gen-asg_profile.name
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      Struct8Debug   = "dSoyaOy7hbpHYVsbxeFUF"
      Name           = "traffic-gen-asg"
      State          = "state-vpc-b"
      Struct8Creator = "rmay struct"
    }
  }
  tags = {
    Name           = "traffic-gen-asg-lt"
    State          = "state-vpc-b"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_autoscaling_group" "traffic-gen-asg" {
  name                  = "traffic-gen-asg"
  desired_capacity      = 2
  health_check_type     = "EC2"
  max_instance_lifetime = 0
  max_size              = 2
  metrics_granularity   = "1Minute"
  min_size              = 2
  termination_policies  = ["Default"]
  vpc_zone_identifier   = [aws_subnet.vpc-b-private.id]
  launch_template {
    version = aws_launch_template.traffic-gen-asg-lt.latest_version
    id      = aws_launch_template.traffic-gen-asg-lt.id
  }
  tag {
    key                 = "Struct8Debug"
    propagate_at_launch = true
    value               = "dSoyaOy7hbpHYVsbxeFUF"
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "traffic-gen-asg"
  }
  tag {
    key                 = "State"
    propagate_at_launch = true
    value               = "state-vpc-b"
  }
  tag {
    key                 = "Struct8Creator"
    propagate_at_launch = true
    value               = "rmay struct"
  }
}
