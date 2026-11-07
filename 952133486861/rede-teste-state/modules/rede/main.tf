resource "aws_vpc" "principal" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "principal"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "publica-a" {
  vpc_id                  = aws_vpc.principal.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "publica-a"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "privada-a" {
  vpc_id                  = aws_vpc.principal.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.20.11.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "privada-a"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

data "aws_ami" "AMI_Data_Source_app-fora" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "app-fora" {
  subnet_id                   = aws_subnet.privada-a.id
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

resource "aws_subnet" "publica-b" {
  vpc_id                  = aws_vpc.principal.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.20.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name           = "publica-b"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "privada-b" {
  vpc_id                  = aws_vpc.principal.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.20.12.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name           = "privada-b"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id
  tags = {
    Name           = "igw"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-publica" {
  vpc_id = aws_vpc.principal.id
  tags = {
    Name           = "rt-publica"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "rt-privada" {
  vpc_id = aws_vpc.principal.id
  tags = {
    Name           = "rt-privada"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-publica_to_igw_ipv4" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.rt-publica.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "instance_app-fora_group" {
  name                   = "instance_app-fora_group"
  vpc_id                 = aws_vpc.principal.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "instance_app-fora_group"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "app-fora_role" {
  name = "app-fora_role"
  assume_role_policy = jsonencode({
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
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "app-fora_role"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_instance_profile" "app-fora_profile" {
  name = "app-fora_profile"
  role = aws_iam_role.app-fora_role.name
  tags = {
    Name           = "app-fora_profile"
    State          = "rede-teste-state"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_publica_a_rt_publica" {
  route_table_id = aws_route_table.rt-publica.id
  subnet_id      = aws_subnet.publica-a.id
}

resource "aws_route_table_association" "aws_route_table_association_privada_a_rt_privada" {
  route_table_id = aws_route_table.rt-privada.id
  subnet_id      = aws_subnet.privada-a.id
}

resource "aws_route_table_association" "aws_route_table_association_publica_b_rt_publica" {
  route_table_id = aws_route_table.rt-publica.id
  subnet_id      = aws_subnet.publica-b.id
}

resource "aws_route_table_association" "aws_route_table_association_privada_b_rt_privada" {
  route_table_id = aws_route_table.rt-privada.id
  subnet_id      = aws_subnet.privada-b.id
}

resource "aws_security_group_rule" "rule_instance_app_fora_group_egress_all_protocols" {
  security_group_id = aws_security_group.instance_app-fora_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

output "privada_a_id" {
  value = aws_subnet.privada-a.id
}

output "privada_b_id" {
  value = aws_subnet.privada-b.id
}

output "publica_a_id" {
  value = aws_subnet.publica-a.id
}

output "publica_b_id" {
  value = aws_subnet.publica-b.id
}

output "principal_id" {
  value = aws_vpc.principal.id
}
