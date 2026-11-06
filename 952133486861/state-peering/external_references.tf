data "aws_vpc" "vpc-a" {
  filter {
    name   = "tag:Name"
    values = ["vpc-a"]
  }
}

data "aws_vpc" "vpc-b" {
  filter {
    name   = "tag:Name"
    values = ["vpc-b"]
  }
}

data "aws_route_table" "rt-vpc-a-private" {
  filter {
    name   = "tag:Name"
    values = ["rt-vpc-a-private"]
  }
}

data "aws_route_table" "rt-vpc-a-public" {
  filter {
    name   = "tag:Name"
    values = ["rt-vpc-a-public"]
  }
}

data "aws_route_table" "rt-vpc-b-private" {
  filter {
    name   = "tag:Name"
    values = ["rt-vpc-b-private"]
  }
}
