resource "aws_iam_openid_connect_provider" "eks_oidc_k8simp13-eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls_k8simp13-eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.k8simp13-eks.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "k8simp13-eks_role" {
  name = "k8simp13-eks_role"
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
    Name           = "k8simp13-eks_role"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_eksng_k8simp13-ng" {
  name = "role_eksng_k8simp13-ng"
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
    Name           = "role_eksng_k8simp13-ng"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp13-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_eksng_k8simp13-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp13-eks_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp13-eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp13-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_eksng_k8simp13-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp13-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_eksng_k8simp13-ng.name
}
