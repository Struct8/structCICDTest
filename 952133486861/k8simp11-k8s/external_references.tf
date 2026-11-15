data "aws_eks_cluster" "k8simp11-cluster" {
  name     = "k8simp11-cluster"
  provider = aws.us_west_2
}
