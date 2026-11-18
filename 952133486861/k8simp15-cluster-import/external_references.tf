data "aws_eks_cluster" "k8simp15-cluster" {
  name     = "k8simp15-cluster"
  provider = aws.us_west_2
}
