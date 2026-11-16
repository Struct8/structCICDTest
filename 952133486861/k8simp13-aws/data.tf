data "tls_certificate" "eks_tls_k8simp13-eks" {
  url = aws_eks_cluster.k8simp13-eks.identity[0].oidc[0].issuer
}
