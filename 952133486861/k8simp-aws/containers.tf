resource "aws_eks_cluster" "k8simp-cluster" {
  version                       = "1.37"
  name                          = "k8simp-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  role_arn                      = aws_iam_role.k8simp-cluster-role.arn
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
    Name           = "k8simp-cluster"
    State          = "k8simp-aws"
    Struct8Creator = "rmay struct"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.k8simp-public-us-west-2a.id, aws_subnet.k8simp-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp-cluster_attach]
}

resource "aws_eks_node_group" "k8simp-ng" {
  cluster_name    = aws_eks_cluster.k8simp-cluster.name
  node_group_name = "k8simp-ng"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]
  node_role_arn   = aws_iam_role.k8simp-node-role.arn
  subnet_ids      = [aws_subnet.k8simp-public-us-west-2a.id, aws_subnet.k8simp-public-us-west-2b.id]
  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp-ng"
    State          = "k8simp-aws"
    Struct8Creator = "rmay struct"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp-ng_attach]
}
