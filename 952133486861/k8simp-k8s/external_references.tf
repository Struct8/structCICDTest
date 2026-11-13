data "aws_eks_cluster" "k8simp-cluster" {
  name     = "k8simp-cluster"
  provider = aws.us_west_2
}
