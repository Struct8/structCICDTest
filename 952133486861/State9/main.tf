terraform {
  required_version = ">= 1.4.0" # Requerido para terraform_data

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
    key            = "step2/State9/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "teste-cicd"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "ekstest1" {
  name = "ekstest1"
}

# --- Instalação dos CRDs via Shell (Evita erro de pasta no Plan) ---
resource "terraform_data" "install_gateway_crds" {
  # Este bloco só roda no Apply, então não quebra o Plan
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${data.aws_eks_cluster.ekstest1.name} --region us-east-1
      kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
    EOT
  }

  # Gatilho para reinstalar se a versão mudar
  triggers_replace = [
    "v1.5.1-standard"
  ]
}

# --- Provider Helm configurado para o EKS ---
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.ekstest1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
      command     = "aws"
    }
  }
}

# --- Instalação do Kong ---
resource "helm_release" "kong1" {
  name             = "kong1"
  chart            = "kong"
  repository       = "https://charts.konghq.com"
  version          = "2.38.0"
  namespace        = "infrab"
  create_namespace = true
  
  values = [
    yamlencode({
      ingressController = {
        enabled = true
        gatewayFeatureGates = "GatewayAlpha=true"
      }
    })
  ]

  # GARANTE que o comando kubectl apply terminou antes de tentar instalar o Kong
  depends_on = [terraform_data.install_gateway_crds]
}

# --- Instalação do ArgoCD ---
resource "helm_release" "helm_Argo1" {
  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd1"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  wait             = true
}