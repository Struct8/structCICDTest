data "local_file" "UserData_nat-windows-secure" {
  filename = "${path.module}/.external_modules/struct8-templates/templates/ec2-nat-private/v1/user_data/Nat.sh"
}

data "aws_ami" "AMI_Data_Source_nat-windows-secure" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "nat-windows-secure" {
  subnet_id                   = aws_subnet.public-windows-secure.id
  ami                         = data.aws_ami.AMI_Data_Source_nat-windows-secure.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.nat-windows-secure_profile.name
  instance_type               = "t3.nano"
  source_dest_check           = false
  user_data_base64 = base64encode(<<-EOFUData
#!/bin/bash

${data.local_file.UserData_nat-windows-secure.content}
EOFUData
)
  vpc_security_group_ids = [aws_security_group.instance_nat-windows-secure_group.id]
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
    Name           = "nat-windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}

data "aws_ami" "AMI_Data_Source_windows-secure" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows-secure" {
  key_name                    = aws_cloudformation_stack.windows-secure-key.outputs["KeyName"]
  subnet_id                   = aws_subnet.private-windows-secure.id
  ami                         = data.aws_ami.AMI_Data_Source_windows-secure.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.windows-secure_profile.name
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.instance_windows-secure_group.id]
  lifecycle {
    ignore_changes = [ami, user_data]
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 75
    volume_type = "gp3"
  }
  tags = {
    Name           = "windows-secure"
    State          = "ec2-windows-secure"
    Struct8Creator = "rmay struct"
  }
}
