data "aws_ami" "AMI_Data_Source_app-fora" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "app-fora" {
  subnet_id                   = module.rede.privada_a_id
  ami                         = data.aws_ami.AMI_Data_Source_app-fora.id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.app-fora_profile.name
  instance_type               = "t3.nano"
  vpc_security_group_ids      = [aws_security_group.instance_app-fora_group.id]
  lifecycle {
    ignore_changes = [user_data]
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
    Name           = "app-fora"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}
