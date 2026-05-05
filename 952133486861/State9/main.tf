terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws  = { source = "hashicorp/aws", version = ">= 5.0" }
    helm = { source = "hashicorp/helm", version = "~> 2.12.1" }
  }

  backend "s3" {
    bucket         = "pro112-teste-cicd"
    key            = "step2/State9/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

provider "aws" { 
  region = "us-east-1" 
}

# --- Dados do Cluster (Necessário para o Helm e para o comando de terminal) ---
data "aws_eks_cluster" "eks" {
  name = "ekstest1"
}

# --- 1. Instalação dos CRDs do Gateway API (O jeito mais simples) ---
resource "terraform_data" "gateway_api_crds" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${data.aws_eks_cluster.eks.name} --region us-east-1
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
    EOT
  }
}

# --- Configuração do Provider Helm ---
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks.name]
      command     = "aws"
    }
  }
}

# --- 2. Instalação do Kong ---
resource "helm_release" "kong1" {
  name             = "kong1"
  chart            = "kong"
  repository       = "https://charts.konghq.com"
  version          = "2.38.0"
  namespace        = "infrab"
  create_namespace = true
  
  # Garante que os CRDs já existam antes de subir o Kong
  depends_on = [terraform_data.gateway_api_crds]

  values = [
    yamlencode({
      ingressController = {
        enabled = true
        gatewayFeatureGates = "GatewayAlpha=true"
      }
    })
  ]
}

# --- 3. Instalação do ArgoCD (A que faltava!) ---
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd1"
  create_namespace = true
  wait             = true
}