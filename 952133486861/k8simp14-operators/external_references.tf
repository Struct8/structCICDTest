data "aws_eks_cluster" "k8simp14-eks" {
  name = "k8simp14-eks"
}




resource "helm_release" "app_secrets_store_csi_driver" {
  name             = "secrets-store-csi-driver"
  chart            = "secrets-store-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  namespace        = "secrets-store-csi-driver-system"
  create_namespace = true
  atomic           = true
  wait             = true
  cleanup_on_fail  = true
  timeout          = 600

  values = [
    yamlencode({
        "syncSecret" = {
          "enabled" = true
        }
        "enableSecretRotation" = true
    }),
    yamlencode({
      "tokenRequests" = [
        { "audience" = "sts.amazonaws.com" },
        { "audience" = "pods.eks.amazonaws.com" }
      ]
    })
  ]
}
