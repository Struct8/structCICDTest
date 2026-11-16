resource "aws_vpc" "k8simp13-vpc" {
  cidr_block           = "10.88.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp13-vpc"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "k8simp13-public-a" {
  vpc_id                  = aws_vpc.k8simp13-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.88.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/k8simp13-eks" = "shared"
    "kubernetes.io/role/elb"             = "1"
    Name                                 = "k8simp13-public-a"
    State                                = "k8simp13-aws"
    Struct8Creator                       = "rmay struct"
  }
}

resource "aws_subnet" "k8simp13-public-b" {
  vpc_id                  = aws_vpc.k8simp13-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.88.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/k8simp13-eks" = "shared"
    "kubernetes.io/role/elb"             = "1"
    Name                                 = "k8simp13-public-b"
    State                                = "k8simp13-aws"
    Struct8Creator                       = "rmay struct"
  }
}

resource "aws_internet_gateway" "k8simp13-igw" {
  vpc_id = aws_vpc.k8simp13-vpc.id
  tags = {
    Name           = "k8simp13-igw"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route" "route_k8simp13-public-rt_to_k8simp13-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp13-igw.id
  route_table_id         = aws_route_table.k8simp13-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp13-public-rt" {
  vpc_id = aws_vpc.k8simp13-vpc.id
  tags = {
    Name           = "k8simp13-public-rt"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp13_public_a_k8simp13_public_rt" {
  route_table_id = aws_route_table.k8simp13-public-rt.id
  subnet_id      = aws_subnet.k8simp13-public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp13_public_b_k8simp13_public_rt" {
  route_table_id = aws_route_table.k8simp13-public-rt.id
  subnet_id      = aws_subnet.k8simp13-public-b.id
}

resource "aws_security_group" "eks_node_group_k8simp13-ng_group" {
  name                   = "eks_node_group_k8simp13-ng_group"
  vpc_id                 = aws_vpc.k8simp13-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "eks_node_group_k8simp13-ng_group"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_eks_node_group_k8simp13_ng_group_egress_all_protocols" {
  security_group_id = aws_security_group.eks_node_group_k8simp13-ng_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_k8simp13-ng_ingress_cluster_to_node_dns_tcp" {
  security_group_id        = aws_security_group.eks_node_group_k8simp13-ng_group.id
  source_security_group_id = aws_eks_cluster.k8simp13-eks.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to DNS pods (TCP)"
  from_port                = 53
  protocol                 = "tcp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp13-ng_ingress_cluster_to_node_dns_udp" {
  security_group_id        = aws_security_group.eks_node_group_k8simp13-ng_group.id
  source_security_group_id = aws_eks_cluster.k8simp13-eks.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to DNS pods (UDP)"
  from_port                = 53
  protocol                 = "udp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp13-ng_ingress_cluster_to_node_kubelet" {
  security_group_id        = aws_security_group.eks_node_group_k8simp13-ng_group.id
  source_security_group_id = aws_eks_cluster.k8simp13-eks.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to Kubelet (logs/exec)"
  from_port                = 10250
  protocol                 = "tcp"
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp13-ng_ingress_cluster_to_node_webhooks" {
  security_group_id        = aws_security_group.eks_node_group_k8simp13-ng_group.id
  source_security_group_id = aws_eks_cluster.k8simp13-eks.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to Node Webhooks (LB Controller, etc)"
  from_port                = 9443
  protocol                 = "tcp"
  to_port                  = 9443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp13-ng_ingress_node_to_node_all" {
  security_group_id        = aws_security_group.eks_node_group_k8simp13-ng_group.id
  source_security_group_id = aws_security_group.eks_node_group_k8simp13-ng_group.id
  description              = "Allow Nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
  type                     = "ingress"
}
