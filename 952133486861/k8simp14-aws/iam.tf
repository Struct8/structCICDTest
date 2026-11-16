resource "aws_iam_instance_profile" "k8simp14-backend_profile" {
  name = "k8simp14-backend_profile"
  role = aws_iam_role.k8simp14-backend_role.name
  tags = {
    Name           = "k8simp14-backend_profile"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_openid_connect_provider" "eks_oidc_k8simp14-eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_tls_k8simp14-eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.k8simp14-eks.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "k8simp14-backend_role" {
  name = "k8simp14-backend_role"
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
    Name           = "k8simp14-backend_role"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "k8simp14-eks_role" {
  name = "k8simp14-eks_role"
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
    Name           = "k8simp14-eks_role"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role" "role_eksng_k8simp14-ng" {
  name = "role_eksng_k8simp14-ng"
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
    Name           = "role_eksng_k8simp14-ng"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly_to_k8simp14-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.role_eksng_k8simp14-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy_to_k8simp14-eks_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8simp14-eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController_to_k8simp14-eks_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8simp14-eks_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy_to_k8simp14-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.role_eksng_k8simp14-ng.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy_to_k8simp14-ng_attach" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.role_eksng_k8simp14-ng.name
}

resource "aws_secretsmanager_secret" "k8simp14-api" {
  name                           = "k8simp14-api"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "k8simp14-api"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret" "k8simp14-db" {
  name                           = "k8simp14-db"
  force_overwrite_replica_secret = false
  recovery_window_in_days        = 0
  tags = {
    Name           = "k8simp14-db"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}

resource "aws_secretsmanager_secret_version" "k8simp14-api_version" {
  secret_id      = aws_secretsmanager_secret.k8simp14-api.id
  secret_string  = "lab-value-api"
  version_stages = ["AWSCURRENT"]
}

resource "aws_secretsmanager_secret_version" "k8simp14-db_version" {
  secret_id      = aws_secretsmanager_secret.k8simp14-db.id
  secret_string  = "lab-value-db"
  version_stages = ["AWSCURRENT"]
}
