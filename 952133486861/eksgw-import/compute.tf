resource "aws_autoscaling_group_tag" "eksgw-ng_name_tag" {
  autoscaling_group_name = aws_eks_node_group.eksgw-ng.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "eksgw-ng"
  }
}
