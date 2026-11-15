data "aws_eks_cluster" "k8simp10-cluster" {
  name     = "k8simp10-cluster"
  provider = aws.us_west_2
}
