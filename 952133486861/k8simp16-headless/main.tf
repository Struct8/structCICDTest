terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket  = "pro112-teste-cicd"
    key     = "952133486861/k8simp16-headless/main.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp16-cluster.certificate_authority[0].data)
    host                   = aws_eks_cluster.k8simp16-cluster.endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp16-cluster.name]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp16-cluster.certificate_authority[0].data)
  host                   = aws_eks_cluster.k8simp16-cluster.endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp16-cluster.name]
    command     = "aws"
  }
}

### CATEGORY: IAM ###

resource "aws_iam_role" "k8simp16-cluster-role" {
  name                  = "k8simp16-cluster-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":[\"sts:AssumeRole\",\"sts:TagSession\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-cluster-role"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role" "k8simp16-node-role" {
  name                  = "k8simp16-node-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-node-role"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp16-ng-lt_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8simp16-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp16-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp16-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp16-ng-lt_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8simp16-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp16-ng-lt_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8simp16-node-role.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "k8simp16-vpc" {
  cidr_block           = "10.89.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp16-vpc"
    Project        = "k8s-import-lab"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_subnet" "k8simp16-public-us-west-2a" {
  vpc_id                              = aws_vpc.k8simp16-vpc.id
  availability_zone                   = "us-west-2a"
  cidr_block                          = "10.89.1.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp16-public-us-west-2a"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp16-cluster" = "shared"
    State                                    = "k8simp16-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_subnet" "k8simp16-public-us-west-2b" {
  vpc_id                              = aws_vpc.k8simp16-vpc.id
  availability_zone                   = "us-west-2b"
  cidr_block                          = "10.89.2.0/24"
  map_public_ip_on_launch             = true
  private_dns_hostname_type_on_launch = "ip-name"
  tags = {
    Name                                     = "k8simp16-public-us-west-2b"
    Project                                  = "k8s-import-lab"
    "kubernetes.io/role/elb"                 = "1"
    "kubernetes.io/cluster/k8simp16-cluster" = "shared"
    State                                    = "k8simp16-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_internet_gateway" "k8simp16-igw" {
  vpc_id = aws_vpc.k8simp16-vpc.id
  tags = {
    Name           = "k8simp16-igw"
    Project        = "k8s-import-lab"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route" "route_k8simp16-public-rt_to_k8simp16-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp16-igw.id
  route_table_id         = aws_route_table.k8simp16-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp16-public-rt" {
  vpc_id = aws_vpc.k8simp16-vpc.id
  tags = {
    Name           = "k8simp16-public-rt"
    Project        = "k8s-import-lab"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp16_public_us_west_2a_k8simp16_public_rt" {
  route_table_id = aws_route_table.k8simp16-public-rt.id
  subnet_id      = aws_subnet.k8simp16-public-us-west-2a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp16_public_us_west_2b_k8simp16_public_rt" {
  route_table_id = aws_route_table.k8simp16-public-rt.id
  subnet_id      = aws_subnet.k8simp16-public-us-west-2b.id
}

resource "aws_security_group" "eks-cluster-sg-k8simp16-cluster-605412344" {
  name        = "eks-cluster-sg-k8simp16-cluster-605412344"
  vpc_id      = aws_vpc.k8simp16-vpc.id
  description = "EKS created security group applied to ENI that is attached to EKS Control Plane master nodes, as well as any managed workloads."
  lifecycle {
    ignore_changes = [revoke_rules_on_delete]
  }
  tags = {
    Name                                     = "eks-cluster-sg-k8simp16-cluster-605412344"
    "kubernetes.io/cluster/k8simp16-cluster" = "owned"
    State                                    = "k8simp16-headless"
    Struct8Creator                           = "Unknown"
  }
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp16_cluster_605412344_egress_all_protocols_from_0_0_0_0_0" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp16-cluster-605412344.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp16_cluster_605412344_egress_all_protocols_from_self" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp16-cluster-605412344.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_eks_cluster_sg_k8simp16_cluster_605412344_ingress_all_protocols" {
  security_group_id = aws_security_group.eks-cluster-sg-k8simp16-cluster-605412344.id
  description       = "Allows EFA traffic, which is not matched by CIDR rules."
  from_port         = 0
  protocol          = "-1"
  self              = true
  to_port           = 0
  type              = "ingress"
}




### CATEGORY: COMPUTE ###

resource "aws_launch_template" "k8simp16-nodes-lt" {
  name            = "k8simp16-nodes-lt"
  default_version = 1
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "k8simp16-lt-node"
      Project = "k8s-import-lab"
    }
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-nodes-lt"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
}




### CATEGORY: CONTAINERS ###

resource "aws_eks_cluster" "k8simp16-cluster" {
  version                       = "1.37"
  name                          = "k8simp16-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  role_arn                      = aws_iam_role.k8simp16-cluster-role.arn
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
    elastic_load_balancing {
      enabled = false
    }
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-cluster"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.k8simp16-public-us-west-2a.id, aws_subnet.k8simp16-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp16-cluster_attach]
}

resource "aws_eks_node_group" "k8simp16-ng-lt" {
  cluster_name    = aws_eks_cluster.k8simp16-cluster.name
  node_group_name = "k8simp16-ng-lt"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]
  node_role_arn   = aws_iam_role.k8simp16-node-role.arn
  subnet_ids      = [aws_subnet.k8simp16-public-us-west-2a.id, aws_subnet.k8simp16-public-us-west-2b.id]
  launch_template {
    version = "1"
    id      = aws_launch_template.k8simp16-nodes-lt.id
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-ng-lt"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp16_public_us_west_2a_k8simp16_public_rt, aws_route.route_k8simp16-public-rt_to_k8simp16-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp16_public_us_west_2b_k8simp16_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp16-ng-lt_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp16-ng-lt_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp16-ng-lt_attach]
}

resource "aws_eks_node_group" "k8simp16-ng-plain" {
  cluster_name    = aws_eks_cluster.k8simp16-cluster.name
  node_group_name = "k8simp16-ng-plain"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]
  node_role_arn   = aws_iam_role.k8simp16-node-role.arn
  subnet_ids      = [aws_subnet.k8simp16-public-us-west-2a.id, aws_subnet.k8simp16-public-us-west-2b.id]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp16-ng-plain"
    State          = "k8simp16-headless"
    Struct8Creator = "Unknown"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp16_public_us_west_2a_k8simp16_public_rt, aws_route.route_k8simp16-public-rt_to_k8simp16-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp16_public_us_west_2b_k8simp16_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp16-ng-lt_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp16-ng-lt_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp16-ng-lt_attach]
}


