data "aws_iam_openid_connect_provider" "eks_oidc_eksgw-cluster" {
  url = aws_eks_cluster.eksgw-cluster.identity[0].oidc[0].issuer
}

data "http" "lbc_iam_policy_eksgw-alb" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
}
