resource "aws_vpc" "k8simp10-vpc" {
  cidr_block           = "10.85.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp10-vpc"
    Project        = "k8s-import-lab"
    State          = "k8simp10-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "k8simp10-public-us-west-2a" {
  vpc_id                              = aws_vpc.k8simp10-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.85.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp10-public-us-west-2a"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/cluster/k8simp10-cluster" = "shared"
    "kubernetes.io/role/elb"                 = "1"
    State                                    = "k8simp10-aws"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_subnet" "k8simp10-public-us-west-2b" {
  vpc_id                              = aws_vpc.k8simp10-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.85.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp10-public-us-west-2b"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/cluster/k8simp10-cluster" = "shared"
    "kubernetes.io/role/elb"                 = "1"
    State                                    = "k8simp10-aws"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_internet_gateway" "k8simp10-igw" {
  vpc_id = aws_vpc.k8simp10-vpc.id
  tags = {
    Name           = "k8simp10-igw"
    Project        = "k8s-import-lab"
    State          = "k8simp10-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_k8simp10-public-rt_to_k8simp10-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp10-igw.id
  route_table_id         = aws_route_table.k8simp10-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp10-public-rt" {
  vpc_id = aws_vpc.k8simp10-vpc.id
  tags = {
    Name           = "k8simp10-public-rt"
    Project        = "k8s-import-lab"
    State          = "k8simp10-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp10_public_us_west_2a_k8simp10_public_rt" {
  route_table_id = aws_route_table.k8simp10-public-rt.id
  subnet_id      = aws_subnet.k8simp10-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp10_public_us_west_2b_k8simp10_public_rt" {
  route_table_id = aws_route_table.k8simp10-public-rt.id
  subnet_id      = aws_subnet.k8simp10-public-us-west-2b.id
}

resource "aws_security_group" "eks-cluster-sg-k8simp10-cluster-1434762766" {
  name        = "eks-cluster-sg-k8simp10-cluster-1434762766"
  vpc_id      = aws_vpc.k8simp10-vpc.id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name                                     = "eks-cluster-sg-k8simp10-cluster-1434762766"
    "kubernetes.io/cluster/k8simp10-cluster" = "owned"
    State                                    = "k8simp10-aws"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp10_cluster_1434762766_egress_all_protocols_from_0_0_0_0_0" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp10-cluster-1434762766.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp10_cluster_1434762766_egress_all_protocols_from_self" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp10-cluster-1434762766.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp10_cluster_1434762766_ingress_all_protocols" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp10-cluster-1434762766.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "ingress"
}
