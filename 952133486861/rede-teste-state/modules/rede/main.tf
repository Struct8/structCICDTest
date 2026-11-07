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

output "privada_a_id" {
  value = aws_subnet.privada-a.id
}

output "principal_id" {
  value = aws_vpc.principal.id
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
