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
    # ADICIONE "data." antes de aws_eks_cluster
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
    host                   = data.aws_eks_cluster.ekstest1.endpoint
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      # ADICIONE "data." aqui também
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
      command     = "aws"
    }
  }
}

### SYSTEM DATA SOURCES ###

data "tls_certificate" "eks_tls_ekstest1" {
  # ADICIONE "data." aqui também
  url = data.aws_eks_cluster.ekstest1.identity[0].oidc[0].issuer
}




### EXTERNAL REFERENCES ###

data "aws_eks_cluster" "ekstest1" {
  name                              = "ekstest1"
}




### CATEGORY: KUBERNETES ###

resource "helm_release" "argocd_applications" {
  version                           = "2.0.0"
  name                              = "argocd-apps"
  chart                             = "argocd-apps"
  namespace                         = "argocd1"
  repository                        = "https://argoproj.github.io/argo-helm"
  values                            = [
    yamlencode({
        applications = {
          master-bootstrap = {
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
  depends_on                        = [helm_release.helm_Argo1]
}

resource "helm_release" "helm_Argo1" {
  name                              = "argocd"
  atomic                            = true
  chart                             = "argo-cd"
  create_namespace                  = true
  namespace                         = "argocd1"
  repository                        = "https://argoproj.github.io/argo-helm"
  timeout                           = 600
  wait                              = true
  values                            = [
    yamlencode({
        configs = {
          repositories = {}
        }
      })
  ]
}




resource "terraform_data" "gateway_api_crds" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${data.aws_eks_cluster.ekstest1.name} --region us-east-1
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
    EOT
  }
}

resource "helm_release" "kong1" {
  name             = "kong1"
  chart            = "kong"
  repository       = "https://charts.konghq.com"
  version          = "2.38.0"
  namespace        = "argocd1"
  create_namespace = false
  atomic           = true
  wait             = true
  cleanup_on_fail  = true
  timeout          = 600

  depends_on = [terraform_data.gateway_api_crds]
}

resource "helm_release" "rmq" {
  name             = "rmq"
  chart            = "rabbitmq"
  repository       = "https://charts.bitnami.com/bitnami"
  version          = "14.4.1"
  namespace        = "argocd1"
  create_namespace = false
  atomic           = true
  wait             = true
  cleanup_on_fail  = true
  timeout          = 600
}

