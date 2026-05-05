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
    # Provider oficial para lidar com a criação dos arquivos temporários locais
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
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

# Configuração do Provider Helm (agora ele é o único responsável por instalar coisas no K8s)
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.ekstest1.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekstest1.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        =["eks", "get-token", "--cluster-name", data.aws_eks_cluster.ekstest1.name]
      command     = "aws"
    }
  }
}

# 1. Busca os CRDs do Gateway API via HTTP na versão mais atual (v1.5.1) e canal STANDARD
data "http" "gateway_api_crds" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml"
}

# 2. O Terraform cria o arquivo Chart.yaml no disco dinamicamente
resource "local_file" "chart_yaml" {
  content  = "apiVersion: v2\nname: gateway-crds\nversion: 1.0.0"
  filename = "${path.module}/meu-chart-temporario/Chart.yaml"
}

# 3. O Terraform cria o arquivo crds.yaml com o conteúdo baixado
resource "local_file" "crds_yaml" {
  content  = data.http.gateway_api_crds.response_body
  filename = "${path.module}/meu-chart-temporario/templates/crds.yaml"
}

# 4. Instala os CRDs usando o Helm (que lê a pasta criada acima)
resource "helm_release" "gateway_api_crds" {
  name      = "gateway-api-crds"
  chart     = "${path.module}/meu-chart-temporario"
  namespace = "kube-system"

  # O Helm só roda DEPOIS que o Terraform criar os arquivos físicos no disco
  depends_on =[
    local_file.chart_yaml,
    local_file.crds_yaml
  ]
}

# 5. Instalação do Kong aguardando o chart local dos CRDs
resource "helm_release" "kong1" {
  name             = "kong1"
  chart            = "kong"
  repository       = "https://charts.konghq.com"
  version          = "2.38.0"
  namespace        = "infrab"
  create_namespace = true
  
  values =[
    yamlencode({
      ingressController = {
        enabled = true
        gatewayFeatureGates = "GatewayAlpha=true"
      }
    })
  ]

  depends_on = [helm_release.gateway_api_crds]
}

# 6. Instalação do ArgoCD (mantida)
resource "helm_release" "helm_Argo1" {
  name             = "argocd"
  chart            = "argo-cd"
  namespace        = "argocd1"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  wait             = true
}