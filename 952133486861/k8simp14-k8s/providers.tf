# --- Main Cloud Provider ---
provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --- Extra Providers ---
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8simp14-eks.certificate_authority[0].data)
    host                   = data.aws_eks_cluster.k8simp14-eks.endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.k8simp14-eks.name]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.k8simp14-eks.certificate_authority[0].data)
  host                   = data.aws_eks_cluster.k8simp14-eks.endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.k8simp14-eks.name]
    command     = "aws"
  }
}
