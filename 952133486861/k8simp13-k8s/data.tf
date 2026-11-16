data "tls_certificate" "eks_tls_k8simp13-eks" {
  url = data.aws_eks_cluster.k8simp13-eks.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks_oidc_k8simp13-eks" {
  url = data.aws_eks_cluster.k8simp13-eks.identity[0].oidc[0].issuer
}
