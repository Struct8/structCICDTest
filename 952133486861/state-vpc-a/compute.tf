data "local_file" "UserData_nat-a" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/user_data/Nat.sh"
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
  subnet_id                   = aws_subnet.vpc-a-public.id
  ami                         = data.aws_ami.AMI_Data_Source_nat-a.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-a_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.5.0.10"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

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
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_traffic-gen-private" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/user_data/PrivateTrafficGenerator.sh"
}

data "aws_ami" "AMI_Data_Source_traffic-gen-private" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "traffic-gen-private" {
  subnet_id                   = aws_subnet.vpc-a-private.id
  ami                         = data.aws_ami.AMI_Data_Source_traffic-gen-private.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.traffic-gen-private_profile.name
  instance_type               = "t3.nano"
  private_ip                  = "10.5.1.10"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

# --- BEGIN STRUCT8 VARIABLES ---
cat << 'EOFENV' > /etc/struct8_env
LISTEN="80/tcp 53/udp"
NAME="traffic-gen-private"
REGION="${data.aws_region.current.region}"
ACCOUNT="${data.aws_caller_identity.current.account_id}"
AWS_S3_BUCKET_NAME_0="traffic-bucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.region}-an"
AWS_DYNAMODB_TABLE_NAME_0="traffic-table-a"
AWS_AUTOSCALING_GROUP_NAME_0="traffic-gen-asg"
AWS_INSTANCE_NAME_0="nat-a"
EOFENV
cat /etc/struct8_env >> /etc/environment
sed 's/^/export /' /etc/struct8_env > /etc/profile.d/struct8_vars.sh
chmod +x /etc/profile.d/struct8_vars.sh
chmod 644 /etc/struct8_env
# --- END STRUCT8 VARIABLES ---

${data.local_file.UserData_traffic-gen-private.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_traffic-gen-private_group.id]
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type             = "one-time"
    }
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
    http_tokens        = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Struct8Debug   = "FX2YywXH644G8HUw23NLU"
    Name           = "traffic-gen-private"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}

data "local_file" "UserData_traffic-gen-public" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/vpc-flowlogs-amp/v1/user_data/FlowLogTrafficGenerator.sh"
}

data "aws_ami" "AMI_Data_Source_traffic-gen-public" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "traffic-gen-public" {
  subnet_id                   = aws_subnet.vpc-a-public.id
  ami                         = data.aws_ami.AMI_Data_Source_traffic-gen-public.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.traffic-gen-public_profile.name
  instance_type               = "t3.nano"
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_traffic-gen-public.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_traffic-gen-public_group.id]
  instance_market_options {
    market_type = "spot"
    spot_options {
      instance_interruption_behavior = "terminate"
      spot_instance_type             = "one-time"
    }
  }
  metadata_options {
    http_endpoint      = "enabled"
    http_protocol_ipv6 = "enabled"
    http_tokens        = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Struct8Debug   = "Sl9JhZ0nMqByjOi8dVpJa"
    Name           = "traffic-gen-public"
    State          = "state-vpc-a"
    Struct8Creator = "rmay struct"
  }
}
