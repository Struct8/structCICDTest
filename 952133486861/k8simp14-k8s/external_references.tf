data "aws_eks_cluster" "k8simp14-eks" {
  name = "k8simp14-eks"
}

data "aws_sqs_queue" "k8simp14-orders" {
  name = "k8simp14-orders"
}

data "aws_security_group" "instance_k8simp14-backend_group" {
  filter {
    name   = "tag:Name"
    values = ["instance_k8simp14-backend_group"]
  }
}

data "aws_secretsmanager_secret" "k8simp14-api" {
  name = "k8simp14-api"
}

data "aws_secretsmanager_secret" "k8simp14-db" {
  name = "k8simp14-db"
}
