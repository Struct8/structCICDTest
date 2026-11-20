resource "aws_iam_role" "k8simp19-cluster-role" {
  name                  = "k8simp19-cluster-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":[\"sts:AssumeRole\",\"sts:TagSession\"],\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-cluster-role"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp19-efs-csi" {
  name                  = "k8simp19-efs-csi"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRoleWithWebIdentity\",\"Condition\":{\"StringLike\":{\"oidc.eks.us-west-2.amazonaws.com/id/2C4164449099776ACFAF2BFA3AD7DA65:aud\":\"sts.amazonaws.com\",\"oidc.eks.us-west-2.amazonaws.com/id/2C4164449099776ACFAF2BFA3AD7DA65:sub\":\"system:serviceaccount:kube-system:efs-csi-*\"}},\"Effect\":\"Allow\",\"Principal\":{\"Federated\":\"arn:aws:iam::952133486861:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/2C4164449099776ACFAF2BFA3AD7DA65\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-efs-csi"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp19-fargate-role" {
  name                  = "k8simp19-fargate-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"eks-fargate-pods.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-fargate-role"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp19-node-role" {
  name                  = "k8simp19-node-role"
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ec2.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-node-role"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp19-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8simp19-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp19-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp19-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSFargatePodExecutionRolePolicy_to_k8simp19-batch_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.k8simp19-fargate-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController_to_k8simp19-cluster_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8simp19-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp19-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8simp19-node-role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp19-arm_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8simp19-node-role.name
}

resource "aws_iam_role_policy_attachment" "service_role_AmazonEFSCSIDriverPolicy_to_aws-efs-csi-driver_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.k8simp19-efs-csi.name
}

resource "aws_kms_key" "a2d39303-3efd-4613-99bb-e5408a82e0bf" {
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "k8simp19 EKS secrets"
  enable_key_rotation      = false
  is_enabled               = true
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
  policy                   = "{\"Id\":\"key-default-1\",\"Statement\":[{\"Action\":\"kms:*\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::952133486861:root\"},\"Resource\":\"*\",\"Sid\":\"Enable IAM User Permissions\"}],\"Version\":\"2012-10-17\"}"
  tags = {
    Project        = "k8s-import-lab"
    Name           = "a2d39303-3efd-4613-99bb-e5408a82e0bf"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}
