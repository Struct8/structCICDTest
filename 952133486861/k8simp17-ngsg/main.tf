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
    tls = {
      source = "hashicorp/tls"
    }
  }

  backend "s3" {
    bucket  = "pro112-teste-cicd"
    key     = "952133486861/k8simp17-ngsg/main.tfstate"
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
    cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp17-eks.certificate_authority[0].data)
    host                   = aws_eks_cluster.k8simp17-eks.endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp17-eks.name]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp17-eks.certificate_authority[0].data)
  host                   = aws_eks_cluster.k8simp17-eks.endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp17-eks.name]
    command     = "aws"
  }
}

### SYSTEM DATA SOURCES ###

data "tls_certificate" "eks_tls_k8simp17-eks" {
  url = aws_eks_cluster.k8simp17-eks.identity[0].oidc[0].issuer
}




### CATEGORY: IAM ###

resource "aws_iam_openid_connect_provider" "eks_oidc_k8simp17-eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls_k8simp17-eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.k8simp17-eks.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "k8simp17-eks_role" {
  name = "k8simp17-eks_role"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      }
    }
  ]
})
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Name           = "k8simp17-eks_role"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role" "role_eksng_k8simp17-ng" {
  name = "role_eksng_k8simp17-ng"
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
    Name           = "role_eksng_k8simp17-ng"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp17-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_eksng_k8simp17-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp17-eks_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp17-eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp17-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_eksng_k8simp17-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp17-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_eksng_k8simp17-ng.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "k8simp17-vpc" {
  cidr_block           = "10.3.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name           = "k8simp17-vpc"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_subnet" "k8simp17-public-a" {
  vpc_id                  = aws_vpc.k8simp17-vpc.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.3.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/k8simp17-eks" = "shared"
    "kubernetes.io/role/elb"             = "1"
    Name                                 = "k8simp17-public-a"
    State                                = "k8simp17-ngsg"
    Struct8Creator                       = "Unknown"
  }
}

resource "aws_subnet" "k8simp17-public-b" {
  vpc_id                  = aws_vpc.k8simp17-vpc.id
  availability_zone       = "us-west-2b"
  cidr_block              = "10.3.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    "kubernetes.io/cluster/k8simp17-eks" = "shared"
    "kubernetes.io/role/elb"             = "1"
    Name                                 = "k8simp17-public-b"
    State                                = "k8simp17-ngsg"
    Struct8Creator                       = "Unknown"
  }
}

resource "aws_internet_gateway" "k8simp17-igw" {
  vpc_id = aws_vpc.k8simp17-vpc.id
  tags = {
    Name           = "k8simp17-igw"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route" "route_k8simp17-public-rt_to_k8simp17-igw_ipv4" {
  gateway_id             = aws_internet_gateway.k8simp17-igw.id
  route_table_id         = aws_route_table.k8simp17-public-rt.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table" "k8simp17-public-rt" {
  vpc_id = aws_vpc.k8simp17-vpc.id
  tags = {
    Name           = "k8simp17-public-rt"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_route_table_association" "aws_route_table_association_k8simp17_public_a_k8simp17_public_rt" {
  route_table_id = aws_route_table.k8simp17-public-rt.id
  subnet_id      = aws_subnet.k8simp17-public-a.id
}

resource "aws_route_table_association" "aws_route_table_association_k8simp17_public_b_k8simp17_public_rt" {
  route_table_id = aws_route_table.k8simp17-public-rt.id
  subnet_id      = aws_subnet.k8simp17-public-b.id
}

resource "aws_security_group" "lb_k8simp17-alb_group" {
  name                   = "lb_k8simp17-alb_group"
  vpc_id                 = aws_vpc.k8simp17-vpc.id
  revoke_rules_on_delete = false
  tags = {
    Name           = "lb_k8simp17-alb_group"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_security_group_rule" "rule_lb_k8simp17_alb_group_egress_all_protocols" {
  security_group_id = aws_security_group.lb_k8simp17-alb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rule_lb_k8simp17_alb_group_ingress_tcp_80" {
  security_group_id = aws_security_group.lb_k8simp17-alb_group.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_k8simp17_alb_group_to_k8simp17_eks_cluster_sg_tcp_10256" {
  security_group_id        = aws_eks_cluster.k8simp17-eks.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.lb_k8simp17-alb_group.id
  description              = "Allow from lb_k8simp17-alb_group (tcp:10256-10256)"
  from_port                = 10256
  protocol                 = "tcp"
  to_port                  = 10256
  type                     = "ingress"
}

resource "aws_lb" "k8simp17-alb" {
  name               = "k8simp17-alb"
  enable_http2       = false
  idle_timeout       = 60
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_k8simp17-alb_group.id]
  subnets            = [aws_subnet.k8simp17-public-a.id, aws_subnet.k8simp17-public-b.id]
  tags = {
    Name           = "k8simp17-alb"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_lb_listener" "k8simp17-listener" {
  load_balancer_arn                    = aws_lb.k8simp17-alb.arn
  port                                 = 80
  protocol                             = "HTTP"
  routing_http_response_server_enabled = true
  default_action {
    order            = 1
    target_group_arn = aws_lb_target_group.k8simp17-tg.arn
    type             = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.k8simp17-tg.arn
      }
    }
  }
  tags = {
    Name           = "k8simp17-listener"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}

resource "aws_lb_target_group" "k8simp17-tg" {
  name                          = "k8simp17-tg"
  vpc_id                        = aws_vpc.k8simp17-vpc.id
  deregistration_delay          = "30"
  ip_address_type               = "ipv4"
  load_balancing_algorithm_type = "round_robin"
  port                          = 10256
  protocol                      = "HTTP"
  target_type                   = "instance"
  health_check {
    matcher  = "200"
    path     = "/healthz"
    port     = "traffic-port"
    protocol = "HTTP"
  }
  tags = {
    Name           = "k8simp17-tg"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
}




### CATEGORY: COMPUTE ###

resource "aws_autoscaling_group_tag" "k8simp17-ng_name_tag" {
  autoscaling_group_name = aws_eks_node_group.k8simp17-ng.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "k8simp17-ng"
  }
}

resource "aws_autoscaling_traffic_source_attachment" "k8simp17-tg_to_k8simp17-ng" {
  autoscaling_group_name = aws_eks_node_group.k8simp17-ng.resources[0].autoscaling_groups[0].name
  traffic_source {
    identifier = aws_lb_target_group.k8simp17-tg.arn
    type       = "elbv2"
  }
}




### CATEGORY: CONTAINERS ###

resource "aws_eks_addon" "coredns_k8simp17-eks" {
  addon_name                  = "coredns"
  cluster_name                = aws_eks_cluster.k8simp17-eks.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp17-ng]
}

resource "aws_eks_addon" "kube_proxy_k8simp17-eks" {
  addon_name                  = "kube-proxy"
  cluster_name                = aws_eks_cluster.k8simp17-eks.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp17-ng]
}

resource "aws_eks_addon" "vpc_cni_k8simp17-eks" {
  addon_name                  = "vpc-cni"
  cluster_name                = aws_eks_cluster.k8simp17-eks.name
  configuration_values        = jsonencode({"env": {"ENABLE_PREFIX_DELEGATION": "true", "WARM_PREFIX_TARGET": "1"}})
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp17-ng]
}

resource "aws_eks_cluster" "k8simp17-eks" {
  version                       = "1.37"
  name                          = "k8simp17-eks"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  enabled_cluster_log_types     = ["api"]
  force_update_version          = false
  role_arn                      = aws_iam_role.k8simp17-eks_role.arn
  tags = {
    Name           = "k8simp17-eks"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.k8simp17-public-a.id, aws_subnet.k8simp17-public-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp17-eks_attach]
}

resource "aws_eks_node_group" "k8simp17-ng" {
  cluster_name    = aws_eks_cluster.k8simp17-eks.name
  node_group_name = "k8simp17-ng"
  instance_types  = ["t3.medium"]
  node_role_arn   = aws_iam_role.role_eksng_k8simp17-ng.arn
  subnet_ids      = [aws_subnet.k8simp17-public-a.id, aws_subnet.k8simp17-public-b.id]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Name           = "k8simp17-ng"
    State          = "k8simp17-ngsg"
    Struct8Creator = "Unknown"
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp17_public_a_k8simp17_public_rt, aws_route.route_k8simp17-public-rt_to_k8simp17-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp17_public_b_k8simp17_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp17-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp17-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp17-ng_attach]
}


