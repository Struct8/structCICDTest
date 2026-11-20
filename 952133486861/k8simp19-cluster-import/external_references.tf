data "aws_eks_cluster" "k8simp19-cluster" {
  name     = "k8simp19-cluster"
  provider = aws.us_west_2
}
