resource "aws_launch_template" "k8simp19-lt" {
  name                   = "k8simp19-lt"
  default_version        = 1
  vpc_security_group_ids = [aws_security_group.k8simp19-nodes-sg.id, aws_eks_cluster.k8simp19-cluster.vpc_config[0].cluster_security_group_id]
  metadata_options {
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "k8simp19-lt-node"
      Project = "k8s-import-lab"
    }
  }
  tags = {
    Project        = "k8s-import-lab"
    Name           = "k8simp19-lt"
    State          = "k8simp19-import"
    Struct8Creator = "rmay struct"
  }
}
