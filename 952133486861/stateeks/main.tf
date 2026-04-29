terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/stateeks/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate          = base64decode(aws_eks_cluster.ekstest.certificate_authority[0].data)
    host                            = aws_eks_cluster.ekstest.endpoint
    exec {
      api_version                   = "client.authentication.k8s.io/v1beta1"
      args                          = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ekstest.name]
      command                       = "aws"
    }
  }
}

### SYSTEM DATA SOURCES ###

data "tls_certificate" "eks_tls_ekstest" {
  url                               = aws_eks_cluster.ekstest.identity[0].oidc[0].issuer
}

data "http" "lbc_iam_policy" {
  url                               = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}




### CATEGORY: IAM ###

resource "aws_iam_openid_connect_provider" "eks_oidc_ekstest" {
  client_id_list                    = ["sts.amazonaws.com"]
  thumbprint_list                   = [data.tls_certificate.eks_tls_ekstest.certificates[0].sha1_fingerprint]
  url                               = aws_eks_cluster.ekstest.identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name                              = "AWSLoadBalancerControllerIAMPolicy"
  description                       = "AWS Load Balancer Controller IAM Policy"
  path                              = "/"
  policy                            = data.http.lbc_iam_policy.response_body
}

data "aws_iam_policy_document" "doc_trust_eks_lb_ekstest" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = [aws_iam_openid_connect_provider.eks_oidc_ekstest.arn]
      type                          = "Federated"
    }
    actions                         = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test                          = "StringEquals"
      values                        = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
      variable                      = "${substr(aws_iam_openid_connect_provider.eks_oidc_ekstest.url, 8, length(aws_iam_openid_connect_provider.eks_oidc_ekstest.url))}:sub"
    }
  }
}

resource "aws_iam_role" "eks_lb_controller_role_ekstest" {
  name                              = "eks_lb_controller_role_ekstest"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_eks_lb_ekstest.json
}

resource "aws_iam_role" "role_eks_ekstest" {
  name                              = "role_eks_ekstest"
  assume_role_policy                = jsonencode({
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
  tags                              = {
    "Name" = "role_eks_ekstest"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_iam_role" "role_eksng_NodeGroup" {
  name                              = "role_eksng_NodeGroup"
  assume_role_policy                = jsonencode({
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
  tags                              = {
    "Name" = "role_eksng_NodeGroup"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerRegistryReadOnly_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSClusterPolicy_to_ekstest" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role                              = aws_iam_role.role_eks_ekstest.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSWorkerNodePolicy_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKS_CNI_Policy_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "eks_lb_controller_role_ekstest_attach" {
  policy_arn                        = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role                              = aws_iam_role.eks_lb_controller_role_ekstest.name
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPCeks" {
  cidr_block                        = "10.4.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    "Name" = "VPCeks"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_subnet" "Subnet15" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.4.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/ekstest" = "shared"
    "kubernetes.io/role/elb" = "1"
    "Name" = "Subnet15"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_subnet" "Subnet16" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.4.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/ekstest" = "shared"
    "kubernetes.io/role/elb" = "1"
    "Name" = "Subnet16"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_subnet" "Subnet17" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.4.2.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "Name" = "Subnet17"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_internet_gateway" "IGWeks" {
  vpc_id                            = aws_vpc.VPCeks.id
  tags                              = {
    "Name" = "IGWeks"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_route" "aws_route_RTeks_IGWeks" {
  gateway_id                        = aws_internet_gateway.IGWeks.id
  route_table_id                    = aws_route_table.RTeks.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route_table" "RTeks" {
  vpc_id                            = aws_vpc.VPCeks.id
  tags                              = {
    "Name" = "RTeks"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_route_table_association" "aws_route_table_association_Subnet15_RTeks" {
  route_table_id                    = aws_route_table.RTeks.id
  subnet_id                         = aws_subnet.Subnet15.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet16_RTeks" {
  route_table_id                    = aws_route_table.RTeks.id
  subnet_id                         = aws_subnet.Subnet16.id
}

resource "aws_route_table_association" "aws_route_table_association_Subnet17_RTeks" {
  route_table_id                    = aws_route_table.RTeks.id
  subnet_id                         = aws_subnet.Subnet17.id
}

resource "aws_security_group" "eks_node_group_NodeGroup_group" {
  name                              = "eks_node_group_NodeGroup_group"
  vpc_id                            = aws_vpc.VPCeks.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "eks_node_group_NodeGroup_group"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_security_group" "lb_alb_ALBeks_group" {
  name                              = "lb_alb_ALBeks_group"
  vpc_id                            = aws_vpc.VPCeks.id
  revoke_rules_on_delete            = false
  tags                              = {
    "Name" = "lb_alb_ALBeks_group"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_eks_node_group_NodeGroup_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALBeks_group_egress_all_protocols" {
  security_group_id                 = aws_security_group.lb_alb_ALBeks_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "egress"
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Template" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_launch_template" "Template" {
  name                              = "Template"
  ebs_optimized                     = true
  instance_type                     = "t3.small"
  update_default_version            = true
  vpc_security_group_ids            = [aws_security_group.eks_node_group_NodeGroup_group.id]
  tags                              = {
    "Name" = "Template"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
}

resource "aws_eks_addon" "vpc_cni_ekstest" {
  addon_name                        = "vpc-cni"
  cluster_name                      = aws_eks_cluster.ekstest.name
  configuration_values              = jsonencode({"env":{"ENABLE_PREFIX_DELEGATION":"true", "WARM_PREFIX_TARGET":"1"}})
  resolve_conflicts                 = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "aws_eks_cluster" "ekstest" {
  version                           = "1.30"
  name                              = "ekstest"
  bootstrap_self_managed_addons     = true
  enabled_cluster_log_types         = ["api"]
  force_update_version              = false
  role_arn                          = aws_iam_role.role_eks_ekstest.arn
  tags                              = {
    "Name" = "ekstest"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
  vpc_config {
    endpoint_private_access         = true
    endpoint_public_access          = true
    public_access_cidrs             = ["0.0.0.0/0"]
    subnet_ids                      = [aws_subnet.Subnet15.id, aws_subnet.Subnet16.id]
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSClusterPolicy_to_ekstest]
}

resource "aws_eks_node_group" "NodeGroup" {
  version                           = "1.30"
  cluster_name                      = aws_eks_cluster.ekstest.name
  node_group_name                   = "NodeGroup"
  node_role_arn                     = aws_iam_role.role_eksng_NodeGroup.arn
  subnet_ids                        = [aws_subnet.Subnet17.id]
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template.id
  }
  remote_access {
    source_security_group_ids       = [aws_security_group.eks_node_group_NodeGroup_group.id]
  }
  scaling_config {
    desired_size                    = 1
    max_size                        = 2
    min_size                        = 1
  }
  tags                              = {
    "Name" = "NodeGroup"
    "State" = "stateeks"
    "Struct8User" = "Ricardo"
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSWorkerNodePolicy_to_NodeGroup, aws_iam_role_policy_attachment.attach_AmazonEKS_CNI_Policy_to_NodeGroup, aws_iam_role_policy_attachment.attach_AmazonEC2ContainerRegistryReadOnly_to_NodeGroup]
}




### CATEGORY: MISC ###

resource "helm_release" "aws_load_balancer_controller" {
  name                              = "aws-load-balancer-controller"
  chart                             = "aws-load-balancer-controller"
  namespace                         = "kube-system"
  repository                        = "https://aws.github.io/eks-charts"
  set {
    name                            = "clusterName"
    value                           = aws_eks_cluster.ekstest.name
  }
  set {
    name                            = "serviceAccount.create"
    value                           = true
  }
  set {
    name                            = "serviceAccount.name"
    value                           = "aws-load-balancer-controller"
  }
  set {
    name                            = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value                           = aws_iam_role.eks_lb_controller_role_ekstest.arn
  }
  set {
    name                            = "vpcId"
    value                           = aws_vpc.VPCeks.id
  }
  set {
    name                            = "region"
    value                           = data.aws_region.current.name
  }
}


