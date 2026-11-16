data "aws_eks_cluster" "k8simp13-eks" {
  name = "k8simp13-eks"
}

data "aws_sqs_queue" "k8simp13-orders" {
  name = "k8simp13-orders"
}

data "aws_security_group" "instance_k8simp13-backend_group" {
  filter {
    name   = "tag:Name"
    values = ["instance_k8simp13-backend_group"]
  }
}

data "aws_secretsmanager_secret" "k8simp13-db" {
  name = "k8simp13-db"
}

data "aws_secretsmanager_secret" "k8simp13-api" {
  name = "k8simp13-api"
}
