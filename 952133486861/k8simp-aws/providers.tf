# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp-cluster.certificate_authority[0].data)
    host                   = aws_eks_cluster.k8simp-cluster.endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp-cluster.name]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(aws_eks_cluster.k8simp-cluster.certificate_authority[0].data)
  host                   = aws_eks_cluster.k8simp-cluster.endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.k8simp-cluster.name]
    command     = "aws"
  }
}
