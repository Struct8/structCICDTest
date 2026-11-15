data "aws_eks_cluster" "k8simp12-cluster" {
  name     = "k8simp12-cluster"
  provider = aws.us_west_2
}
