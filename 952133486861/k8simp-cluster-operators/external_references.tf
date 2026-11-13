data "aws_eks_cluster" "k8simp-cluster" {
  name     = "k8simp-cluster"
  provider = aws.us_west_2
}




resource "helm_release" "app_secrets_store_csi_driver" {
  name             = "csi-secrets-store"
  chart            = "secrets-store-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  version          = "1.6.2"
  namespace        = "kube-system"
  reuse_values     = true
  create_namespace = false
  atomic           = false
  wait             = true
  cleanup_on_fail  = false
  timeout          = 300
}

resource "helm_release" "app_external_secrets" {
  name             = "external-secrets"
  chart            = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  version          = "2.15.0"
  namespace        = "external-secrets"
  reuse_values     = true
  create_namespace = false
  atomic           = false
  wait             = true
  cleanup_on_fail  = false
  timeout          = 300

  depends_on = [helm_release.app_secrets_store_csi_driver]
}
