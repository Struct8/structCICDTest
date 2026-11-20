resource "helm_release" "argocd_applications" {
  version    = "1.4.1"
  name       = "argocd-apps"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 300
  values = [
    yamlencode({
        applications = {
          argocd-root-struct8-structcicdtest = {
            name       = "argocd-root-struct8-structcicdtest"
            namespace  = "argocd"
            finalizers = ["resources-finalizer.argocd.argoproj.io"]
            project    = "default"
            source = {
              repoURL        = "https://github.com/Struct8/structCICDTest"
              targetRevision = "HEAD"
              path           = "."
              directory = {
                recurse = true
                include = "{**/application-*.32n0321wkxwigaxfisroe.yaml,**/imageupdater-*.32n0321wkxwigaxfisroe.yaml}"
              }
            }
            destination = {
              server    = "https://kubernetes.default.svc"
              namespace = "argocd"
            }
            syncPolicy = {
              automated = {
                prune      = true
                selfHeal   = true
                allowEmpty = true
              }
            }
          }
        }
      })
  ]
  depends_on = [helm_release.argocd_projects, helm_release.helm_argocd, kubernetes_namespace.argocd, kubernetes_namespace.batch, kubernetes_namespace.store]
}

resource "helm_release" "argocd_projects" {
  version    = "1.4.1"
  name       = "argocd-projects"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 300
  values = [
    yamlencode({
        projects = {
          k8simp19 = {
            name        = "k8simp19"
            namespace   = "argocd"
            description = ""
            sourceRepos = ["https://github.com/Struct8/structCICDTest"]
            destinations = [
              {
                server    = "https://kubernetes.default.svc"
                namespace = "*"
              }
            ]
            clusterResourceWhitelist = [
              {
                group = "*"
                kind  = "*"
              }
            ]
          }
        }
      })
  ]
  depends_on = [helm_release.helm_argocd, kubernetes_namespace.argocd, kubernetes_namespace.batch, kubernetes_namespace.store]
}

resource "helm_release" "helm_argocd" {
  version          = "10.18.2"
  name             = "argocd"
  atomic           = false
  chart            = "argo-cd"
  create_namespace = false
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  reuse_values     = true
  timeout          = 300
  wait             = true
  values = [
    yamlencode({
        configs = {
          repositories = {
            struct8-structcicdtest = {
              name = "struct8-structcicdtest"
              url  = "https://github.com/Struct8/structCICDTest"
              type = "git"
            }
          }
        }
      })
  ]
  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}

resource "kubernetes_namespace" "batch" {
  metadata {
    name = "batch"
  }
}

resource "kubernetes_namespace" "store" {
  metadata {
    name = "store"
  }
}
