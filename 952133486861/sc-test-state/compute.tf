data "local_file" "UserData_sc-test-nat" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_sc-test-nat" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "sc-test-nat" {
  subnet_id                   = aws_subnet.sc-test-nat-public.id
  ami                         = data.aws_ami.AMI_Data_Source_sc-test-nat.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.sc-test-nat_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_sc-test-nat.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_sc-test-nat_group.id]
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
    Name           = "sc-test-nat"
    State          = "sc-test-state"
    Struct8Creator = "rmay struct"
  }
}
