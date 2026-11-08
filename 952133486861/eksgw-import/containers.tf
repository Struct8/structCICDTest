resource "aws_eks_cluster" "eksgw-cluster" {
  version                       = "1.37"
  name                          = "eksgw-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  role_arn                      = aws_iam_role.eksgw-cluster-role.arn
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
    Project        = "eks-gw-lab"
    Name           = "eksgw-cluster"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [aws_subnet.eksgw-public-us-west-2a.id, aws_subnet.eksgw-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_eksgw-cluster_attach]
}

resource "aws_eks_node_group" "eksgw-ng" {
  cluster_name    = aws_eks_cluster.eksgw-cluster.name
  node_group_name = "eksgw-ng"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t3.small"]
  node_role_arn   = aws_iam_role.eksgw-node-role.arn
  subnet_ids      = [aws_subnet.eksgw-public-us-west-2a.id, aws_subnet.eksgw-public-us-west-2b.id]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  tags = {
    Project        = "eks-gw-lab"
    Name           = "eksgw-ng"
    State          = "eksgw-import"
    Struct8Creator = "rmay struct"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_eksgw-ng_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_eksgw-ng_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_eksgw-ng_attach]
}
