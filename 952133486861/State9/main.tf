terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "952133486861/State9/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate          = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
    host                            = data.aws_eks_cluster.ekstest1.endpoint
    exec {
      api_version                   = "client.authentication.k8s.io/v1beta1"
      args                          = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
      command                       = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate            = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
  host                              = data.aws_eks_cluster.ekstest1.endpoint
  exec {
    api_version                     = "client.authentication.k8s.io/v1beta1"
    args                            = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
    command                         = "aws"
  }
}

### SYSTEM DATA SOURCES ###

data "tls_certificate" "eks_tls_ekstest1" {
  url                               = data.aws_eks_cluster.ekstest1.identity[0].oidc[0].issuer
}




### EXTERNAL REFERENCES ###

data "aws_eks_cluster" "ekstest1" {
  name                              = "ekstest1"
}

data "aws_lb_target_group" "TG" {
  name                              = "TG"
}




### CATEGORY: KUBERNETES ###

resource "helm_release" "argocd_applications" {
  version                           = "1.4.1"
  name                              = "argocd-apps"
  chart                             = "argocd-apps"
  namespace                         = kubernetes_namespace.argocd1.metadata[0].name
  repository                        = "https://argoproj.github.io/argo-helm"
  values                            = [
    yamlencode({
        applications = {
          struct8-testargo-bootstrap = {
            name = "struct8-testargo-bootstrap"
            namespace = "argocd1"
            finalizers = ["resources-finalizer.argocd.argoproj.io"]
            project = "default"
            source = {
              repoURL = "https://github.com/Struct8/TestArgo.git"
              targetRevision = "HEAD"
              path = "bootstrap"
            }
            destination = {
              server = "https://kubernetes.default.svc"
              namespace = "argocd1"
            }
            syncPolicy = {
              automated = {
                prune = true
                selfHeal = true
              }
            }
          }
        }
      })
  ]
  depends_on                        = [helm_release.helm_Argo1, kubernetes_namespace.argocd1]
}

resource "helm_release" "helm_Argo1" {
  name                              = "argo1"
  atomic                            = true
  chart                             = "argo-cd"
  create_namespace                  = false
  namespace                         = kubernetes_namespace.argocd1.metadata[0].name
  repository                        = "https://argoproj.github.io/argo-helm"
  timeout                           = 600
  wait                              = true
  
  values                            = [
    yamlencode({
        configs = {
          repositories = {
            struct8-testargo = {
              name = "struct8-testargo"
              url = "https://github.com/Struct8/TestArgo.git"
              type = "git"
            }
          }
        }
        server = {
          extraArgs = ["--insecure"]
          metrics = {
            enabled = true
            serviceMonitor = {
              enabled = true
              interval = "30s"
              scrapeTimeout = "10s"
              # Label para o Prometheus encontrar este ServiceMonitor
              additionalLabels = {
                release = "kube-prometheus-stack" 
              }
            }
          }
        }
        controller = {
          metrics = {
            enabled = true
            serviceMonitor = {
              enabled = true
              interval = "30s"
              scrapeTimeout = "10s"
              additionalLabels = {
                release = "kube-prometheus-stack"
              }
            }
          }
        }
        repoServer = {
          metrics = {
            enabled = true
            serviceMonitor = {
              enabled = true
              interval = "30s"
              scrapeTimeout = "10s"
              additionalLabels = {
                release = "kube-prometheus-stack"
              }
            }
          }
        }
        applicationSet = {
          metrics = {
            enabled = true
            serviceMonitor = {
              enabled = true
              interval = "30s"
              scrapeTimeout = "10s"
              additionalLabels = {
                release = "kube-prometheus-stack"
              }
            }
          }
        }
      })
  ]

  # IMPORTANTE: O Argo CD depende do Prometheus Stack para criar os ServiceMonitors
  depends_on = [
    kubernetes_namespace.argocd1,
    helm_release.prometheus_operator # Alterado de app_kube_prometheus_stack para prometheus_operator
  ]

}

resource "kubernetes_manifest" "tgb_tg" {
  manifest                          = {
    apiVersion = "elbv2.k8s.aws/v1beta1"
    kind = "TargetGroupBinding"
    metadata = {
      name = "tg-tgb"
      namespace = "${kubernetes_namespace.infrab.metadata[0].name}"
    }
    spec = {
      targetGroupARN = "${data.aws_lb_target_group.TG.arn}"
      targetType = "ip"
      serviceRef = {
        name = "kong-proxy"
        port = 80
      }
    }
  }
}

resource "kubernetes_namespace" "argocd1" {
  metadata {
    name                            = "argocd1"
  }
}

resource "kubernetes_namespace" "infrab" {
  metadata {
    name                            = "infrab"
  }
}

resource "kubernetes_namespace" "monitoringtest" {
  metadata {
    name                            = "monitoringtest"
  }
}




resource "terraform_data" "gateway_api_crds" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${data.aws_eks_cluster.ekstest1.name} --region us-east-1
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
    EOT
  }
}

resource "helm_release" "app_kong" {
  name             = "kong"
  chart            = "kong"
  repository       = "https://charts.konghq.com"
  version          = "2.44.0"
  namespace        = "kong-system"
  create_namespace = true
  atomic           = true
  wait             = true
  cleanup_on_fail  = true
  timeout          = 600

  set {
    name  = "ingressController.enabled"
    value = "false"
  }

  set {
    name  = "deployment.kong.enabled"
    value = "false"
  }

  set {
    name  = "migrations.install"
    value = "false"
  }

  set {
    name  = "migrations.preUpgrade"
    value = "false"
  }

  depends_on = [terraform_data.gateway_api_crds]
}

resource "helm_release" "prometheus_operator" {
  name             = "prom-operator"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring-system"
  create_namespace = true

  values = [
    yamlencode({
      prometheus: { enabled: false },
      alertmanager: { enabled: false },
      grafana: { enabled: false }, # Desativamos o Grafana "comum"
      prometheusOperator: { enabled: true }
    })
  ]
}

# 2. O "Cérebro" do Grafana (Necessário para usar kind: Grafana)
resource "helm_release" "grafana_operator" {
  name             = "graf-operator"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana-operator"
  namespace        = "monitoring-system"
  create_namespace = true
  
  # Este operador é o que permite o seu gerador usar "kind: Grafana"
}

