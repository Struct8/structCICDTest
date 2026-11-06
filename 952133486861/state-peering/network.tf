resource "aws_vpc_peering_connection" "peering-a-b" {
  peer_vpc_id = data.aws_vpc.vpc-a.id
  vpc_id      = data.aws_vpc.vpc-b.id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = false
  }
  requester {
    allow_remote_vpc_dns_resolution = false
  }
  tags = {
    Name           = "peering-a-b"
    State          = "state-peering"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_rt-vpc-a-private_to_peering-a-b_10_1_0_0_16" {
  route_table_id            = data.aws_route_table.rt-vpc-a-private.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-a-b.id
  destination_cidr_block    = "10.1.0.0/16"
}

resource "aws_route" "route_rt-vpc-a-public_to_peering-a-b_10_1_0_0_16" {
  route_table_id            = data.aws_route_table.rt-vpc-a-public.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-a-b.id
  destination_cidr_block    = "10.1.0.0/16"
}

resource "aws_route" "route_rt-vpc-b-private_to_peering-a-b_10_5_0_0_16" {
  route_table_id            = data.aws_route_table.rt-vpc-b-private.id
  vpc_peering_connection_id = aws_vpc_peering_connection.peering-a-b.id
  destination_cidr_block    = "10.5.0.0/16"
}

resource "aws_route" "route_rt-vpc-b-private_to_peering-a-b_ipv6" {
  route_table_id              = data.aws_route_table.rt-vpc-b-private.id
  vpc_peering_connection_id   = aws_vpc_peering_connection.peering-a-b.id
  destination_ipv6_cidr_block = data.aws_vpc.vpc-a.ipv6_cidr_block
}
