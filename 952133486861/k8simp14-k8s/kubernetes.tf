resource "helm_release" "app_secrets_store_csi_driver_provider_aws" {
  name             = "secrets-store-csi-driver-provider-aws"
  atomic           = true
  chart            = "secrets-store-csi-driver-provider-aws"
  cleanup_on_fail  = true
  create_namespace = true
  namespace        = "secrets-store-csi-driver-provider-aws-system"
  repository       = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  timeout          = 600
  wait             = true
  set {
    name  = "secrets-store-csi-driver.install"
    value = false
  }
}

resource "helm_release" "argocd_applications" {
  version    = "1.4.1"
  name       = "argocd-apps"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 600
  values = [
    yamlencode({
        applications = {
          k8simp14-argocd-root-struct8-structcicdtest = {
            name       = "k8simp14-argocd-root-struct8-structcicdtest"
            namespace  = "argocd"
            finalizers = ["resources-finalizer.argocd.argoproj.io"]
            project    = "default"
            source = {
              repoURL        = "https://github.com/Struct8/structCICDTest.git"
              targetRevision = "HEAD"
              path           = "."
              directory = {
                recurse = true
                include = "{**/application-*.djkvtb77nm2q5jexewnfs.yaml,**/imageupdater-*.djkvtb77nm2q5jexewnfs.yaml}"
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
  depends_on = [helm_release.argocd_projects, helm_release.helm_k8simp14-argocd, kubernetes_namespace.argocd, kubernetes_namespace.shop-a, kubernetes_namespace.shop-b, aws_iam_role.role_irsa_shop_a_web, aws_iam_role.role_irsa_shop_b_web, aws_iam_role_policy.policy_role_irsa_shop_a_web, aws_iam_role_policy.policy_role_irsa_shop_b_web, aws_security_group.shop_a_web_pod_sg, aws_security_group.shop_b_web_pod_sg, aws_security_group_rule.rule_cluster_to_shop_a_web_pod_sg_tcp_80, aws_security_group_rule.rule_cluster_to_shop_b_web_pod_sg_tcp_80, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080]
}

resource "helm_release" "argocd_projects" {
  version    = "1.4.1"
  name       = "argocd-projects"
  chart      = "argocd-apps"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  timeout    = 600
  values = [
    yamlencode({
        projects = {
          k8simp14 = {
            name        = "k8simp14"
            namespace   = "argocd"
            description = ""
            sourceRepos = ["https://github.com/Struct8/structCICDTest.git"]
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
  depends_on = [helm_release.helm_k8simp14-argocd, kubernetes_namespace.argocd, kubernetes_namespace.shop-a, kubernetes_namespace.shop-b]
}

resource "helm_release" "helm_k8simp14-argocd" {
  name             = "k8simp14-argocd"
  atomic           = true
  chart            = "argo-cd"
  create_namespace = false
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  repository       = "https://argoproj.github.io/argo-helm"
  timeout          = 600
  wait             = true
  values = [
    yamlencode({
        configs = {
          repositories = {
            struct8-structcicdtest = {
              name = "struct8-structcicdtest"
              url  = "https://github.com/Struct8/structCICDTest.git"
              type = "git"
            }
          }
        }
        server = {
          extraArgs = ["--insecure"]
        }
      })
  ]
  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_manifest" "sa_shop_a_web_sa" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "web-sa"
      namespace = kubernetes_namespace.shop-a.metadata[0].name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.role_irsa_shop_a_web.arn
      }
    }
  }
}

resource "kubernetes_manifest" "sa_shop_b_web_sa" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata = {
      name      = "web-sa"
      namespace = kubernetes_namespace.shop-b.metadata[0].name
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.role_irsa_shop_b_web.arn
      }
    }
  }
}

resource "kubernetes_manifest" "sgp_shop_a_web_pod_sg" {
  manifest = {
    apiVersion = "vpcresources.k8s.aws/v1beta1"
    kind       = "SecurityGroupPolicy"
    metadata = {
      name      = "web-sgp"
      namespace = kubernetes_namespace.shop-a.metadata[0].name
    }
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "web"
        }
      }
      securityGroups = {
        groupIds = [aws_security_group.shop_a_web_pod_sg.id]
      }
    }
  }
}

resource "kubernetes_manifest" "sgp_shop_b_web_pod_sg" {
  manifest = {
    apiVersion = "vpcresources.k8s.aws/v1beta1"
    kind       = "SecurityGroupPolicy"
    metadata = {
      name      = "web-sgp"
      namespace = kubernetes_namespace.shop-b.metadata[0].name
    }
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "web"
        }
      }
      securityGroups = {
        groupIds = [aws_security_group.shop_b_web_pod_sg.id]
      }
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [aws_iam_role.role_irsa_shop_a_web, aws_iam_role.role_irsa_shop_b_web, aws_iam_role_policy.policy_role_irsa_shop_a_web, aws_iam_role_policy.policy_role_irsa_shop_b_web, aws_security_group.shop_a_web_pod_sg, aws_security_group.shop_b_web_pod_sg, aws_security_group_rule.rule_cluster_to_shop_a_web_pod_sg_tcp_80, aws_security_group_rule.rule_cluster_to_shop_b_web_pod_sg_tcp_80, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080]
}

resource "kubernetes_namespace" "shop-a" {
  metadata {
    name = "shop-a"
  }
  depends_on = [aws_iam_role.role_irsa_shop_a_web, aws_iam_role.role_irsa_shop_b_web, aws_iam_role_policy.policy_role_irsa_shop_a_web, aws_iam_role_policy.policy_role_irsa_shop_b_web, aws_security_group.shop_a_web_pod_sg, aws_security_group.shop_b_web_pod_sg, aws_security_group_rule.rule_cluster_to_shop_a_web_pod_sg_tcp_80, aws_security_group_rule.rule_cluster_to_shop_b_web_pod_sg_tcp_80, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080]
}

resource "kubernetes_namespace" "shop-b" {
  metadata {
    name = "shop-b"
  }
  depends_on = [aws_iam_role.role_irsa_shop_a_web, aws_iam_role.role_irsa_shop_b_web, aws_iam_role_policy.policy_role_irsa_shop_a_web, aws_iam_role_policy.policy_role_irsa_shop_b_web, aws_security_group.shop_a_web_pod_sg, aws_security_group.shop_b_web_pod_sg, aws_security_group_rule.rule_cluster_to_shop_a_web_pod_sg_tcp_80, aws_security_group_rule.rule_cluster_to_shop_b_web_pod_sg_tcp_80, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_a_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_apiserver, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_tcp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_cluster_dns_udp, aws_security_group_rule.rule_shop_b_web_pod_sg_to_instance_k8simp14_backend_group_tcp_8080]
}
