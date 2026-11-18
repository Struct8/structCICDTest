data "aws_eks_cluster" "k8simp15-cluster" {
  name     = "k8simp15-cluster"
  provider = aws.us_west_2
}




resource "helm_release" "app_argocd_image_updater" {
  name             = "argocd-image-updater"
  chart            = "argocd-image-updater"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "1.5.0"
  namespace        = "argocd"
  reuse_values     = true
  create_namespace = false
  atomic           = false
  wait             = true
  cleanup_on_fail  = false
  timeout          = 300
}

resource "helm_release" "app_grafana_operator" {
  name             = "grafana-operator"
  chart            = "grafana-operator"
  repository       = "https://grafana.github.io/helm-charts"
  version          = "5.26.0"
  namespace        = "grafana-operator"
  reuse_values     = true
  create_namespace = false
  atomic           = false
  wait             = true
  cleanup_on_fail  = false
  timeout          = 300

  depends_on = [helm_release.app_argocd_image_updater]
}

resource "helm_release" "app_kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "93.3.1"
  namespace        = "monitoring"
  reuse_values     = true
  create_namespace = false
  atomic           = false
  wait             = true
  cleanup_on_fail  = false
  timeout          = 300

  depends_on = [helm_release.app_grafana_operator]
}
