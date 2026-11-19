data "aws_eks_cluster" "k8simp18-cluster" {
  name     = "k8simp18-cluster"
  provider = aws.us_west_2
}
