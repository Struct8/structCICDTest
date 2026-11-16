resource "aws_eks_addon" "coredns_k8simp13-eks" {
  addon_name                  = "coredns"
  cluster_name                = aws_eks_cluster.k8simp13-eks.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp13-ng]
}

resource "aws_eks_addon" "kube_proxy_k8simp13-eks" {
  addon_name                  = "kube-proxy"
  cluster_name                = aws_eks_cluster.k8simp13-eks.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp13-ng]
}

resource "aws_eks_addon" "vpc_cni_k8simp13-eks" {
  addon_name                  = "vpc-cni"
  cluster_name                = aws_eks_cluster.k8simp13-eks.name
  configuration_values        = jsonencode({"env": {"ENABLE_PREFIX_DELEGATION": "true", "WARM_PREFIX_TARGET": "1"}})
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on                  = [aws_eks_node_group.k8simp13-ng]
}

resource "aws_eks_cluster" "k8simp13-eks" {
  version                       = "1.37"
  name                          = "k8simp13-eks"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  enabled_cluster_log_types     = ["api"]
  force_update_version          = false
  role_arn                      = aws_iam_role.k8simp13-eks_role.arn
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags = {
    Name           = "k8simp13-eks"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.k8simp13-public-a.id, aws_subnet.k8simp13-public-b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp13-eks_attach]
}

resource "aws_eks_node_group" "k8simp13-ng" {
  cluster_name    = aws_eks_cluster.k8simp13-eks.name
  node_group_name = "k8simp13-ng"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["m5.large"]
  node_role_arn   = aws_iam_role.role_eksng_k8simp13-ng.arn
  subnet_ids      = [aws_subnet.k8simp13-public-a.id, aws_subnet.k8simp13-public-b.id]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  tags = {
    Name           = "k8simp13-ng"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp13_public_a_k8simp13_public_rt, aws_route.route_k8simp13-public-rt_to_k8simp13-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp13_public_b_k8simp13_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp13-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp13-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp13-ng_attach]
}
