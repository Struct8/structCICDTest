resource "aws_eks_addon" "aws-ebs-csi-driver" {
  addon_name    = "aws-ebs-csi-driver"
  cluster_name  = aws_eks_cluster.k8simp19-cluster.name
  addon_version = "v1.68.1-eksbuild.1"
  namespace_config {
    namespace = "kube-system"
  }
  pod_identity_association {
    role_arn        = "arn:aws:iam::952133486861:role/k8simp19-ebs-csi"
    service_account = "ebs-csi-controller-sa"
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "aws-ebs-csi-driver"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eks_addon" "aws-efs-csi-driver" {
  addon_name               = "aws-efs-csi-driver"
  cluster_name             = aws_eks_cluster.k8simp19-cluster.name
  addon_version            = "v3.6.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.k8simp19-efs-csi.arn
  namespace_config {
    namespace = "kube-system"
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "aws-efs-csi-driver"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.service_role_AmazonEFSCSIDriverPolicy_to_aws-efs-csi-driver_attach]
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  addon_name    = "eks-pod-identity-agent"
  cluster_name  = aws_eks_cluster.k8simp19-cluster.name
  addon_version = "v1.4.1-eksbuild.3"
  namespace_config {
    namespace = "kube-system"
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "eks-pod-identity-agent"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eks_addon" "metrics-server" {
  addon_name    = "metrics-server"
  cluster_name  = aws_eks_cluster.k8simp19-cluster.name
  addon_version = "v0.9.1-eksbuild.2"
  namespace_config {
    namespace = "kube-system"
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "metrics-server"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_eks_cluster" "k8simp19-cluster" {
  version                       = "1.37"
  name                          = "k8simp19-cluster"
  bootstrap_self_managed_addons = true
  deletion_protection           = false
  enabled_cluster_log_types     = ["api", "audit", "authenticator"]
  role_arn                      = aws_iam_role.k8simp19-cluster-role.arn
  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.a2d39303-3efd-4613-99bb-e5408a82e0bf.arn
    }
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
    Name           = "k8simp19-cluster"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  upgrade_policy {
    support_type = "EXTENDED"
  }
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/1", "128.0.0.0/1"]
    subnet_ids              = [aws_subnet.k8simp19-private-us-west-2a.id, aws_subnet.k8simp19-public-us-west-2a.id, aws_subnet.k8simp19-private-us-west-2b.id, aws_subnet.k8simp19-public-us-west-2b.id]
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy_to_k8simp19-cluster_attach, aws_iam_role_policy_attachment.AmazonEKSVPCResourceController_to_k8simp19-cluster_attach]
}

resource "aws_eks_fargate_profile" "k8simp19-batch" {
  cluster_name           = aws_eks_cluster.k8simp19-cluster.name
  fargate_profile_name   = "k8simp19-batch"
  pod_execution_role_arn = aws_iam_role.k8simp19-fargate-role.arn
  subnet_ids             = [aws_subnet.k8simp19-private-us-west-2a.id, aws_subnet.k8simp19-private-us-west-2b.id]
  selector {
    namespace = "batch"
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-batch"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_iam_role_policy_attachment.AmazonEKSFargatePodExecutionRolePolicy_to_k8simp19-batch_attach]
}

resource "aws_eks_node_group" "k8simp19-arm" {
  cluster_name    = aws_eks_cluster.k8simp19-cluster.name
  node_group_name = "k8simp19-arm"
  ami_type        = "AL2023_ARM_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["t4g.medium"]
  node_role_arn   = aws_iam_role.k8simp19-node-role.arn
  subnet_ids      = [aws_subnet.k8simp19-private-us-west-2a.id, aws_subnet.k8simp19-private-us-west-2b.id]
  labels = {
    pool = "arm"
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-arm"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp19_private_us_west_2a_k8simp19_private_rt, aws_route.route_k8simp19-private-rt_to_k8simp19-nat_ipv4, aws_route_table_association.aws_route_table_association_k8simp19_private_us_west_2b_k8simp19_private_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp19-arm_attach]
}

resource "aws_eks_node_group" "k8simp19-lt" {
  cluster_name    = aws_eks_cluster.k8simp19-cluster.name
  node_group_name = "k8simp19-lt"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "ON_DEMAND"
  instance_types  = ["m5.large"]
  node_role_arn   = aws_iam_role.k8simp19-node-role.arn
  subnet_ids      = [aws_subnet.k8simp19-public-us-west-2a.id, aws_subnet.k8simp19-public-us-west-2b.id]
  labels = {
    pool = "lt"
  }
  launch_template {
    version = "1"
    id      = aws_launch_template.k8simp19-lt.id
  }
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-lt"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp19_public_us_west_2a_k8simp19_public_rt, aws_route.route_k8simp19-public-rt_to_k8simp19-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp19_public_us_west_2b_k8simp19_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp19-arm_attach]
}

resource "aws_eks_node_group" "k8simp19-spot" {
  cluster_name    = aws_eks_cluster.k8simp19-cluster.name
  node_group_name = "k8simp19-spot"
  ami_type        = "AL2023_x86_64_STANDARD"
  capacity_type   = "SPOT"
  instance_types  = ["t3.medium", "t3a.medium"]
  node_role_arn   = aws_iam_role.k8simp19-node-role.arn
  subnet_ids      = [aws_subnet.k8simp19-public-us-west-2a.id, aws_subnet.k8simp19-public-us-west-2b.id]
  labels = {
    pool = "spot"
  }
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-spot"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
  taint {
    effect = "NO_SCHEDULE"
    key    = "workload"
    value  = "batch"
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp19_public_us_west_2a_k8simp19_public_rt, aws_route.route_k8simp19-public-rt_to_k8simp19-igw_ipv4, aws_route_table_association.aws_route_table_association_k8simp19_public_us_west_2b_k8simp19_public_rt, aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy_to_k8simp19-arm_attach, aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly_to_k8simp19-arm_attach]
}
