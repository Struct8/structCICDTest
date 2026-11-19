resource "aws_launch_template" "k8simp18-lt" {
  name                   = "k8simp18-lt"
  default_version        = 1
  vpc_security_group_ids = [aws_security_group.k8simp18-secure-pod-sg.id, aws_security_group.eks-cluster-sg-k8simp18-cluster-1285470714.id, aws_eks_cluster.k8simp18-cluster.vpc_config[0].cluster_security_group_id]
  metadata_options {
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "k8simp18-lt-node"
      Project = "k8s-import-lab"
    }
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp18-lt"
    State          = "k8simp18-import"
    Struct8Creator = "rmay struct"
  }
}
