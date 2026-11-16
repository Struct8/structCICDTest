resource "aws_cloudwatch_log_group" "k8simp14-eks-logs" {
  name              = "/aws/eks/k8simp14-eks/cluster"
  log_group_class   = "STANDARD"
  retention_in_days = 1
  skip_destroy      = false
  tags = {
    Name           = "k8simp14-eks-logs"
    State          = "k8simp14-aws"
    Struct8Creator = "rmay struct"
  }
}
