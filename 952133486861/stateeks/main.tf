terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
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
    cluster_ca_certificate          = base64decode(aws_eks_cluster.ekstest1.certificate_authority[0].data)
    host                            = aws_eks_cluster.ekstest1.endpoint
    exec {
      api_version                   = "client.authentication.k8s.io/v1beta1"
      args                          = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ekstest1.name]
      command                       = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate            = base64decode(aws_eks_cluster.ekstest1.certificate_authority[0].data)
  host                              = aws_eks_cluster.ekstest1.endpoint
  exec {
    api_version                     = "client.authentication.k8s.io/v1beta1"
    args                            = ["eks", "get-token", "--cluster-name", aws_eks_cluster.ekstest1.name]
    command                         = "aws"
  }
}

### SYSTEM DATA SOURCES ###

data "aws_route53_zone" "Zone" {
  name                              = "cloudman.pro"
}

data "tls_certificate" "eks_tls_ekstest1" {
  url                               = aws_eks_cluster.ekstest1.identity[0].oidc[0].issuer
}

data "http" "lbc_iam_policy_albeks" {
  url                               = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}




### CATEGORY: IAM ###

resource "aws_iam_openid_connect_provider" "eks_oidc_ekstest1" {
  client_id_list                    = ["sts.amazonaws.com"]
  thumbprint_list                   = [data.tls_certificate.eks_tls_ekstest1.certificates[0].sha1_fingerprint]
  url                               = aws_eks_cluster.ekstest1.identity[0].oidc[0].issuer
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy_albeks" {
  name                              = "AWSLoadBalancerControllerIAMPolicy_albeks"
  description                       = "AWS Load Balancer Controller IAM Policy"
  path                              = "/"
  policy                            = data.http.lbc_iam_policy_albeks.response_body
}

data "aws_iam_policy_document" "policy_external_dns_ekstest1_st_stateeks_doc" {
  statement {
    sid                             = "AllowRoute53Changes"
    effect                          = "Allow"
    actions                         = ["route53:ChangeResourceRecordSets"]
    resources                       = [data.aws_route53_zone.Zone.arn]
  }
  statement {
    sid                             = "AllowRoute53Listing"
    effect                          = "Allow"
    actions                         = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources                       = ["*"]
  }
}

resource "aws_iam_policy" "policy_external_dns_ekstest1_st_stateeks" {
  name                              = "policy_external_dns_ekstest1_st_stateeks"
  description                       = "External-DNS Route53 permissions for ekstest1"
  policy                            = data.aws_iam_policy_document.policy_external_dns_ekstest1_st_stateeks_doc.json
  tags                              = {
    Name = "policy_external_dns_ekstest1_st_stateeks"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

data "aws_iam_policy_document" "doc_trust_lbc_albeks" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = [aws_iam_openid_connect_provider.eks_oidc_ekstest1.arn]
      type                          = "Federated"
    }
    actions                         = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test                          = "StringEquals"
      values                        = ["system:serviceaccount:kube-system:aws-lbc-albeks"]
      variable                      = "${substr(aws_iam_openid_connect_provider.eks_oidc_ekstest1.url, 8, length(aws_iam_openid_connect_provider.eks_oidc_ekstest1.url))}:sub"
    }
  }
}

resource "aws_iam_role" "role_eks_ekstest1" {
  name                              = "role_eks_ekstest1"
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
    Name = "role_eks_ekstest1"
    State = "stateeks"
    Struct8User = "Ricardo"
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
    Name = "role_eksng_NodeGroup"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

data "aws_iam_policy_document" "doc_trust_external_dns_ekstest1" {
  statement {
    effect                          = "Allow"
    principals {
      identifiers                   = [aws_iam_openid_connect_provider.eks_oidc_ekstest1.arn]
      type                          = "Federated"
    }
    actions                         = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test                          = "StringEquals"
      values                        = ["system:serviceaccount:kube-system:external-dns"]
      variable                      = "${replace(aws_iam_openid_connect_provider.eks_oidc_ekstest1.url, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role" "role_external_dns_ekstest1_st_stateeks" {
  name                              = "role_external_dns_ekstest1_st_stateeks"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_external_dns_ekstest1.json
  tags                              = {
    Name = "role_external_dns_ekstest1_st_stateeks"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_iam_role" "role_lbc_albeks" {
  name                              = "role_lbc_albeks"
  assume_role_policy                = data.aws_iam_policy_document.doc_trust_lbc_albeks.json
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerRegistryReadOnly_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSClusterPolicy_to_ekstest1" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role                              = aws_iam_role.role_eks_ekstest1.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKSWorkerNodePolicy_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEKS_CNI_Policy_to_NodeGroup" {
  policy_arn                        = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                              = aws_iam_role.role_eksng_NodeGroup.name
}

resource "aws_iam_role_policy_attachment" "attach_ext_dns_ekstest1_st_stateeks" {
  policy_arn                        = aws_iam_policy.policy_external_dns_ekstest1_st_stateeks.arn
  role                              = aws_iam_role.role_external_dns_ekstest1_st_stateeks.name
}

resource "aws_iam_role_policy_attachment" "role_lbc_albeks_attach" {
  policy_arn                        = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy_albeks.arn
  role                              = aws_iam_role.role_lbc_albeks.name
}

resource "aws_acm_certificate" "k8s" {
  domain_name                       = "k8s.cloudman.pro"
  key_algorithm                     = "RSA_2048"
  subject_alternative_names         = ["*.k8s.cloudman.pro"]
  validation_method                 = "DNS"
  lifecycle {
    create_before_destroy           = true
  }
  options {
    certificate_transparency_logging_preference = "ENABLED"
  }
  tags                              = {
    "kubernetes.io/cluster/GAPI" = "shared"
    Name = "k8s"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_acm_certificate_validation" "Validation_k8s" {
  certificate_arn                   = aws_acm_certificate.k8s.arn
  validation_record_fqdns           = [for record in aws_route53_record.Route53_Record_k8s_k8s_cloudman_pro : record.fqdn]
}




### CATEGORY: NETWORK ###

resource "aws_vpc" "VPCeks" {
  cidr_block                        = "10.4.0.0/16"
  instance_tenancy                  = "default"
  tags                              = {
    Name = "VPCeks"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Subnet15" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.4.0.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/ekstest1" = "shared"
    Name = "Subnet15"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Subnet16" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1b"
  cidr_block                        = "10.4.1.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/ekstest1" = "shared"
    "kubernetes.io/role/elb" = "1"
    Name = "Subnet16"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_subnet" "Subnet17" {
  vpc_id                            = aws_vpc.VPCeks.id
  availability_zone                 = "us-east-1a"
  cidr_block                        = "10.4.2.0/24"
  map_public_ip_on_launch           = true
  tags                              = {
    "kubernetes.io/cluster/ekstest1" = "shared"
    "kubernetes.io/role/elb" = "1"
    Name = "Subnet17"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_internet_gateway" "IGWeks" {
  vpc_id                            = aws_vpc.VPCeks.id
  tags                              = {
    Name = "IGWeks"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_route" "aws_route_RTeks_IGWeks" {
  gateway_id                        = aws_internet_gateway.IGWeks.id
  route_table_id                    = aws_route_table.RTeks.id
  destination_cidr_block            = "0.0.0.0/0"
}

resource "aws_route53_record" "Route53_Record_k8s_k8s_cloudman_pro" {
  for_each                          = {
    for dvo in aws_acm_certificate.k8s.domain_validation_options : dvo.domain_name => dvo
    if dvo.domain_name == "k8s.cloudman.pro"
  }
  name                              = "${each.value.resource_record_name}"
  zone_id                           = data.aws_route53_zone.Zone.zone_id
  allow_overwrite                   = true
  records                           = ["${each.value.resource_record_value}"]
  ttl                               = 300
  type                              = "${each.value.resource_record_type}"
}

resource "aws_route_table" "RTeks" {
  vpc_id                            = aws_vpc.VPCeks.id
  tags                              = {
    Name = "RTeks"
    State = "stateeks"
    Struct8User = "Ricardo"
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
    Name = "eks_node_group_NodeGroup_group"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group" "lb_alb_ALBeks_group" {
  name                              = "lb_alb_ALBeks_group"
  vpc_id                            = aws_vpc.VPCeks.id
  revoke_rules_on_delete            = false
  tags                              = {
    Name = "lb_alb_ALBeks_group"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_security_group_rule" "rule_NodeGroup_ingress_cluster_to_node_dns_tcp" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_eks_cluster.ekstest1.vpc_config[0].cluster_security_group_id
  description                       = "Allow Control Plane to DNS pods (TCP)"
  from_port                         = 53
  protocol                          = "tcp"
  to_port                           = 53
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_NodeGroup_ingress_cluster_to_node_dns_udp" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_eks_cluster.ekstest1.vpc_config[0].cluster_security_group_id
  description                       = "Allow Control Plane to DNS pods (UDP)"
  from_port                         = 53
  protocol                          = "udp"
  to_port                           = 53
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_NodeGroup_ingress_cluster_to_node_kubelet" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_eks_cluster.ekstest1.vpc_config[0].cluster_security_group_id
  description                       = "Allow Control Plane to Kubelet (logs/exec)"
  from_port                         = 10250
  protocol                          = "tcp"
  to_port                           = 10250
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_NodeGroup_ingress_cluster_to_node_webhooks" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_eks_cluster.ekstest1.vpc_config[0].cluster_security_group_id
  description                       = "Allow Control Plane to Node Webhooks (LB Controller, etc)"
  from_port                         = 443
  protocol                          = "tcp"
  to_port                           = 443
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_NodeGroup_ingress_node_to_node_all" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_security_group.eks_node_group_NodeGroup_group.id
  description                       = "Allow Nodes to communicate with each other"
  from_port                         = 0
  protocol                          = "-1"
  to_port                           = 0
  type                              = "ingress"
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

resource "aws_security_group_rule" "rule_lb_alb_ALBeks_group_ingress_tcp_443" {
  security_group_id                 = aws_security_group.lb_alb_ALBeks_group.id
  cidr_blocks                       = ["0.0.0.0/0"]
  description                       = "permits https"
  from_port                         = 9443
  protocol                          = "tcp"
  to_port                           = 9443
  type                              = "ingress"
}

resource "aws_security_group_rule" "rule_lb_alb_ALBeks_group_to_eks_node_group_NodeGroup_group_tcp_0_65535" {
  security_group_id                 = aws_security_group.eks_node_group_NodeGroup_group.id
  source_security_group_id          = aws_security_group.lb_alb_ALBeks_group.id
  description                       = "permits all ports form ALB"
  from_port                         = 0
  protocol                          = "tcp"
  to_port                           = 65535
  type                              = "ingress"
}




### CATEGORY: COMPUTE ###

data "aws_ami" "AMI_Data_Source_Template" {
  most_recent                       = true
  owners                            = ["amazon"]
  filter {
    name                            = "name"
    values                          = ["amazon-eks-node-*-v*"]
  }
}

resource "aws_launch_template" "Template" {
  name                              = "Template"
  ebs_optimized                     = true
  instance_type                     = "t3.medium"
  update_default_version            = true
  vpc_security_group_ids            = [aws_security_group.eks_node_group_NodeGroup_group.id, aws_eks_cluster.ekstest1.vpc_config[0].cluster_security_group_id]
  tags                              = {
    Name = "Template"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
}

resource "aws_eks_addon" "coredns_ekstest1" {
  addon_name                        = "coredns"
  cluster_name                      = aws_eks_cluster.ekstest1.name
  resolve_conflicts_on_create       = "OVERWRITE"
  resolve_conflicts_on_update       = "OVERWRITE"
  depends_on                        = [aws_eks_node_group.NodeGroup]
}

resource "aws_eks_addon" "kube_proxy_ekstest1" {
  addon_name                        = "kube-proxy"
  cluster_name                      = aws_eks_cluster.ekstest1.name
  resolve_conflicts_on_create       = "OVERWRITE"
  resolve_conflicts_on_update       = "OVERWRITE"
  depends_on                        = [aws_eks_node_group.NodeGroup]
}

resource "aws_eks_addon" "vpc_cni_ekstest1" {
  addon_name                        = "vpc-cni"
  cluster_name                      = aws_eks_cluster.ekstest1.name
  configuration_values              = jsonencode({"env":{"ENABLE_PREFIX_DELEGATION":"true", "WARM_PREFIX_TARGET":"1"}})
  resolve_conflicts_on_create       = "OVERWRITE"
  resolve_conflicts_on_update       = "OVERWRITE"
  depends_on                        = [aws_eks_node_group.NodeGroup]
}

resource "aws_eks_cluster" "ekstest1" {
  version                           = "1.32"
  name                              = "ekstest1"
  bootstrap_self_managed_addons     = true
  deletion_protection               = false
  enabled_cluster_log_types         = ["api"]
  force_update_version              = false
  role_arn                          = aws_iam_role.role_eks_ekstest1.arn
  access_config {
    authentication_mode             = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags                              = {
    Name = "ekstest1"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
  vpc_config {
    endpoint_private_access         = true
    endpoint_public_access          = true
    public_access_cidrs             = ["0.0.0.0/0"]
    subnet_ids                      = [aws_subnet.Subnet15.id, aws_subnet.Subnet16.id]
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSClusterPolicy_to_ekstest1]
}

resource "aws_eks_node_group" "NodeGroup" {
  cluster_name                      = aws_eks_cluster.ekstest1.name
  node_group_name                   = "NodeGroup"
  node_role_arn                     = aws_iam_role.role_eksng_NodeGroup.arn
  subnet_ids                        = [aws_subnet.Subnet17.id, aws_subnet.Subnet16.id]
  launch_template {
    version                         = "$Latest"
    id                              = aws_launch_template.Template.id
  }
  scaling_config {
    desired_size                    = 1
    max_size                        = 2
    min_size                        = 1
  }
  tags                              = {
    Name = "NodeGroup"
    State = "stateeks"
    Struct8User = "Ricardo"
  }
  depends_on                        = [aws_iam_role_policy_attachment.attach_AmazonEKSWorkerNodePolicy_to_NodeGroup, aws_iam_role_policy_attachment.attach_AmazonEKS_CNI_Policy_to_NodeGroup, aws_iam_role_policy_attachment.attach_AmazonEC2ContainerRegistryReadOnly_to_NodeGroup]
}




### CATEGORY: KUBERNETES ###

resource "helm_release" "aws_lbc_albeks" {
  name                              = "aws-lbc-albeks"
  chart                             = "aws-load-balancer-controller"
  namespace                         = "kube-system"
  repository                        = "https://aws.github.io/eks-charts"
  set {
    name                            = "clusterName"
    value                           = aws_eks_cluster.ekstest1.name
  }
  set {
    name                            = "serviceAccount.create"
    value                           = true
  }
  set {
    name                            = "serviceAccount.name"
    value                           = "aws-lbc-albeks"
  }
  set {
    name                            = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value                           = aws_iam_role.role_lbc_albeks.arn
  }
  depends_on                        = [aws_iam_role_policy_attachment.role_lbc_albeks_attach, aws_eks_node_group.NodeGroup]
}


