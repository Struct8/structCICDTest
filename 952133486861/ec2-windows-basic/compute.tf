data "aws_ami" "AMI_Data_Source_windows-basic" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

resource "aws_instance" "windows-basic" {
  key_name                    = aws_cloudformation_stack.windows-basic-key.outputs["KeyName"]
  subnet_id                   = aws_subnet.public-windows-basic.id
  ami                         = data.aws_ami.AMI_Data_Source_windows-basic.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.windows-basic_profile.name
  instance_type               = "t3.medium"
  vpc_security_group_ids      = [aws_security_group.instance_windows-basic_group.id]
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
    Name           = "windows-basic"
    State          = "ec2-windows-basic"
    Struct8Creator = "rmay struct"
  }
}
