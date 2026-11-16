data "aws_ami" "AMI_Data_Source_k8simp13-backend" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "k8simp13-backend" {
  subnet_id              = aws_subnet.k8simp13-public-a.id
  ami                    = data.aws_ami.AMI_Data_Source_k8simp13-backend.id
  iam_instance_profile   = aws_iam_instance_profile.k8simp13-backend_profile.name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.instance_k8simp13-backend_group.id]
  lifecycle {
    ignore_changes = [user_data]
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    encrypted   = true
    iops        = 3000
    throughput  = 125
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name           = "k8simp13-backend"
    State          = "k8simp13-aws"
    Struct8Creator = "rmay struct"
  }
  depends_on = [aws_route_table_association.aws_route_table_association_k8simp13_public_a_k8simp13_public_rt, aws_route.route_k8simp13-public-rt_to_k8simp13-igw_ipv4]
}

resource "aws_autoscaling_group_tag" "k8simp13-ng_name_tag" {
  autoscaling_group_name = aws_eks_node_group.k8simp13-ng.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "k8simp13-ng"
  }
}
