resource "helm_release" "helm_argocd" {
  version          = "10.18.0"
  name             = "argocd"
  atomic           = false
  chart            = "argo-cd"
  create_namespace = false
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  reuse_values     = true
  timeout          = 300
  wait             = true
  depends_on       = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "app-a" {
  metadata {
    name = "app-a"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}
