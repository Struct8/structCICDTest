resource "aws_vpc" "eksimp-vpc" {
  cidr_block           = "10.77.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Project        = "eks-import-lab"
    Name           = "eksimp-vpc"
    State          = "eks-import-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-public-us-west-2a" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.77.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Project                                = "eks-import-lab"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/eksimp-cluster" = "shared"
    Name                                   = "eksimp-public-us-west-2a"
    State                                  = "eks-import-lab"
    Struct8Creator                         = "rmay struct"
  }
}

resource "aws_subnet" "eksimp-public-us-west-2b" {
  vpc_id                              = aws_vpc.eksimp-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.77.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Project                                = "eks-import-lab"
    "kubernetes.io/role/elb"               = "1"
    "kubernetes.io/cluster/eksimp-cluster" = "shared"
    Name                                   = "eksimp-public-us-west-2b"
    State                                  = "eks-import-lab"
    Struct8Creator                         = "rmay struct"
  }
}

resource "aws_internet_gateway" "eksimp-igw" {
  vpc_id = aws_vpc.eksimp-vpc.id
  tags = {
    Project        = "eks-import-lab"
    Name           = "eksimp-igw"
    State          = "eks-import-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_eksimp-public-rt_to_eksimp-igw_ipv4" {
  gateway_id             = aws_internet_gateway.eksimp-igw.id
  route_table_id         = aws_route_table.eksimp-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "eksimp-public-rt" {
  vpc_id = aws_vpc.eksimp-vpc.id
  tags = {
    Project        = "eks-import-lab"
    Name           = "eksimp-public-rt"
    State          = "eks-import-lab"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_public_us_west_2a_eksimp_public_rt" {
  route_table_id = aws_route_table.eksimp-public-rt.id
  subnet_id      = aws_subnet.eksimp-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_eksimp_public_us_west_2b_eksimp_public_rt" {
  route_table_id = aws_route_table.eksimp-public-rt.id
  subnet_id      = aws_subnet.eksimp-public-us-west-2b.id
}
