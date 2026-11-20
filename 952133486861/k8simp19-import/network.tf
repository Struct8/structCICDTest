resource "aws_vpc" "k8simp19-vpc" {
  cidr_block           = "10.89.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp19-vpc"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_subnet" "k8simp19-private-us-west-2a" {
  vpc_id                              = aws_vpc.k8simp19-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.89.11.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp19-private-us-west-2a"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/k8simp19-cluster" = "shared"
    State                                    = "k8simp19-import"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_subnet" "k8simp19-private-us-west-2b" {
  vpc_id                              = aws_vpc.k8simp19-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.89.12.0/24"
  map_public_ip_on_launch             = false
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp19-private-us-west-2b"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/k8simp19-cluster" = "shared"
    State                                    = "k8simp19-import"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_subnet" "k8simp19-public-us-west-2a" {
  vpc_id                              = aws_vpc.k8simp19-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.89.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp19-public-us-west-2a"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp19-cluster" = "shared"
    State                                    = "k8simp19-import"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_subnet" "k8simp19-public-us-west-2b" {
  vpc_id                              = aws_vpc.k8simp19-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.89.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp19-public-us-west-2b"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp19-cluster" = "shared"
    State                                    = "k8simp19-import"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_internet_gateway" "k8simp19-igw" {
  vpc_id = aws_vpc.k8simp19-vpc.id
  tags = {
    Name           = "k8simp19-igw"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_nat_gateway" "k8simp19-nat" {
  allocation_id     = aws_eip.k8simp19-nat-eip.id
  subnet_id         = aws_subnet.k8simp19-public-us-west-2a.id
  availability_mode = "zonal"
  private_ip        = "10.89.1.87"
  tags = {
    Name           = "k8simp19-nat"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_internet_gateway.k8simp19-igw]
}

resource "aws_route" "route_k8simp19-private-rt_to_k8simp19-nat_ipv4" {
  nat_gateway_id         = aws_nat_gateway.k8simp19-nat.id
  route_table_id         = aws_route_table.k8simp19-private-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "route_k8simp19-public-rt_to_k8simp19-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp19-igw.id
  route_table_id         = aws_route_table.k8simp19-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp19-private-rt" {
  vpc_id = aws_vpc.k8simp19-vpc.id
  tags = {
    Name           = "k8simp19-private-rt"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table" "k8simp19-public-rt" {
  vpc_id = aws_vpc.k8simp19-vpc.id
  tags = {
    Name           = "k8simp19-public-rt"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp19_private_us_west_2a_k8simp19_private_rt" {
  route_table_id = aws_route_table.k8simp19-private-rt.id
  subnet_id      = aws_subnet.k8simp19-private-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp19_private_us_west_2b_k8simp19_private_rt" {
  route_table_id = aws_route_table.k8simp19-private-rt.id
  subnet_id      = aws_subnet.k8simp19-private-us-west-2b.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp19_public_us_west_2a_k8simp19_public_rt" {
  route_table_id = aws_route_table.k8simp19-public-rt.id
  subnet_id      = aws_subnet.k8simp19-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp19_public_us_west_2b_k8simp19_public_rt" {
  route_table_id = aws_route_table.k8simp19-public-rt.id
  subnet_id      = aws_subnet.k8simp19-public-us-west-2b.id
}

resource "aws_security_group" "eks-cluster-sg-k8simp19-cluster-521983749" {
  name        = "eks-cluster-sg-k8simp19-cluster-521983749"
  vpc_id      = aws_vpc.k8simp19-vpc.id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name                                     = "eks-cluster-sg-k8simp19-cluster-521983749"
    "kubernetes.io/cluster/k8simp19-cluster" = "owned"
    State                                    = "k8simp19-import"
    Struct8Creator                           = "rmay struct"
  }
}

resource "aws_security_group" "k8simp19-nodes-sg" {
  name        = "k8simp19-nodes-sg"
  vpc_id      = aws_vpc.k8simp19-vpc.id
  description = "k8simp19 launch template nodes"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "k8simp19-nodes-sg"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group" "k8simp19-secure-pod-sg" {
  name        = "k8simp19-secure-pod-sg"
  vpc_id      = aws_vpc.k8simp19-vpc.id
  description = "k8simp19 pod secure"
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name           = "k8simp19-secure-pod-sg"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp19_cluster_521983749_egress_all_protocols_from_0_0_0_0_0" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp19_cluster_521983749_egress_all_protocols_from_self" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp19_cluster_521983749_ingress_all_protocols" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp19_cluster_521983749_to_k8simp19_nodes_sg_tcp_10250" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  description              = "kubelet from the control plane"
  from_port                = 10250
  protocol                 = "tcp"
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp19_cluster_521983749_to_k8simp19_secure_pod_sg_all_protocols" {
  security_group_id        = aws_security_group.k8simp19-secure-pod-sg.id
  source_security_group_id = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  description              = "from the cluster"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19-lt_ingress_cluster_to_node_dns_tcp" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_eks_cluster.k8simp19-cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to DNS pods (TCP)"
  from_port                = 53
  protocol                 = "tcp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19-lt_ingress_cluster_to_node_dns_udp" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_eks_cluster.k8simp19-cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to DNS pods (UDP)"
  from_port                = 53
  protocol                 = "udp"
  to_port                  = 53
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19-lt_ingress_cluster_to_node_kubelet" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_eks_cluster.k8simp19-cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to Kubelet (logs/exec)"
  from_port                = 10250
  protocol                 = "tcp"
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19-lt_ingress_cluster_to_node_webhooks" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_eks_cluster.k8simp19-cluster.vpc_config[0].cluster_security_group_id
  description              = "Allow Control Plane to Node Webhooks (LB Controller, etc)"
  from_port                = 9443
  protocol                 = "tcp"
  to_port                  = 9443
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19-lt_ingress_node_to_node_all" {
  security_group_id        = aws_security_group.k8simp19-nodes-sg.id
  source_security_group_id = aws_security_group.k8simp19-nodes-sg.id
  description              = "Allow Nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_security_group_rule" "rule_k8simp19_nodes_sg_egress_all_protocols" {
  security_group_id = aws_security_group.k8simp19-nodes-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_k8simp19_secure_pod_sg_egress_all_protocols" {
  security_group_id = aws_security_group.k8simp19-secure-pod-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_k8simp19_secure_pod_sg_to_eks_cluster_sg_k8simp19_cluster_521983749_all_protocols" {
  security_group_id        = aws_security_group.eks-cluster-sg-k8simp19-cluster-521983749.id
  source_security_group_id = aws_security_group.k8simp19-secure-pod-sg.id
  description              = "pod secure to dns and nodes"
  from_port                = 0
  protocol                 = "-1"
  to_port                  = 0
  type                     = "ingress"
}

resource "aws_eip" "k8simp19-nat-eip" {
  network_border_group = "us-west-2"
  public_ipv4_pool     = "amazon"
  tags = {
    Name           = "k8simp19-nat-eip"
    Project        = "k8s-import-lab"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}
