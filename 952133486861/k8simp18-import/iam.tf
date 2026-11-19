resource "aws_iam_role" "k8simp18-cluster-role" {
  name                  = "k8simp18-cluster-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":[\"sts:AssumeRole\",\"sts:TagSession\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp18-cluster-role"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp18-efs-csi" {
  name                  = "k8simp18-efs-csi"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Condition\":{\"StringLike\":{\"oidc.eks.us-west-2.amazonaws.com/id/C8CCD92EEC2EB6705A8A59A6ED418A6C:aud\":\"sts.amazonaws.com\",\"oidc.eks.us-west-2.amazonaws.com/id/C8CCD92EEC2EB6705A8A59A6ED418A6C:sub\":\"system:serviceaccount:kube-system:efs-csi-*\"}},\"Effect\":\"Allow\",\"Principal\":{\"Federated\":\"arn:aws:iam::952133486861:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/C8CCD92EEC2EB6705A8A59A6ED418A6C\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp18-efs-csi"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp18-fargate-role" {
  name                  = "k8simp18-fargate-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks-fargate-pods.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp18-fargate-role"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp18-node-role" {
  name                  = "k8simp18-node-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp18-node-role"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp18-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8simp18-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp18-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp18-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy_to_k8simp18-batch_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.k8simp18-fargate-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController_to_k8simp18-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8simp18-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp18-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8simp18-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp18-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8simp18-node-role.name
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonEFSCSIDriverPolicy_to_aws-efs-csi-driver_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.k8simp18-efs-csi.name
}

resource "aws_kms_key" "c9b5aad2-3fb4-4feb-a112-7518a6dd7c29" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "k8simp18 EKS secrets"
  enable_key_rotation      = false
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = "{\"Id\":\"key-default-1\",\"Statement\":[{\"Action\":\"kms:*\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::952133486861:root\"},\"Resource\":\"*\",\"Sid\":\"Enable IAM User Permissions\"}],\"Version\":\"2012-10-17\"}"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "c9b5aad2-3fb4-4feb-a112-7518a6dd7c29"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}
