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
    # Adicionando o provider kubectl para gerenciar manifestos brutos
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
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

# --- Providers Setup ---
provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "ekstest1" {
  name = "ekstest1"
}

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


# Configuração do Provider Kubectl (igual ao Helm)
provider "kubectl" {
  host                   = data.aws_eks_cluster.ekstest1.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
    command     = "aws"
  }
}

# 1. Busca os CRDs do Gateway API via HTTP
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/experimental-install.yaml"
}

# 2. Divide o arquivo YAML (que tem vários documentos) e aplica um por um
resource "kubectl_manifest" "gateway_api" {
  for_each = {
    for idx, manifest in split("---", data.http.gateway_api_crds.response_body) :
    idx => manifest
    if trimspace(manifest) != "" && length(regexall("(?i)kind:", manifest)) > 0
  }

  yaml_body = each.value

  lifecycle {
    ignore_changes = [yaml_body]
  }
}


# 3. Agora o Kong pode ser instalado via Helm normalmente, 
# pois os CRDs já estarão lá graças ao 'depends_on'
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

  depends_on = [kubectl_manifest.gateway_api]
}

# 4. Instalação do ArgoCD (mantida)
resource "helm_release" "helm_Argo1" {
  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd1"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  wait             = true
}
