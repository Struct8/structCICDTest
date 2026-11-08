data "tls_certificate" "eks_tls_eksimp-cluster" {
  url = aws_eks_cluster.eksimp-cluster.identity[0].oidc[0].issuer
}
