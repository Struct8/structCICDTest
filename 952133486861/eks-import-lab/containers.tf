resource "aws_eks_cluster" "eksimp-cluster" {
  version                       = "1.37"
  name                          = "eksimp-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  role_arn                      = aws_iam_role.eksimp-cluster-role.arn
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
    Project        = "eks-import-lab"
    Name           = "eksimp-cluster"
    State          = "eks-import-lab"
    Struct8Creator = "rmay struct"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.eksimp-public-us-west-2a.id, aws_subnet.eksimp-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_eksimp-cluster_attach]
}

resource "aws_eks_node_group" "eksimp-ng" {
  cluster_name    = aws_eks_cluster.eksimp-cluster.name
  node_group_name = "eksimp-ng"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.medium"]
  node_role_arn   = aws_iam_role.eksimp-node-role.arn
  subnet_ids      = [aws_subnet.eksimp-public-us-west-2a.id, aws_subnet.eksimp-public-us-west-2b.id]
  labels = {
    role = "general"
  }
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  tags = {
    Project        = "eks-import-lab"
    Name           = "eksimp-ng"
    State          = "eks-import-lab"
    Struct8Creator = "rmay struct"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_eksimp-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_eksimp-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_eksimp-ng_attach]
}
