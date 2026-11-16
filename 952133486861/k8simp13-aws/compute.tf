resource "aws_autoscaling_group_tag" "k8simp13-ng_name_tag" {
  autoscaling_group_name = aws_eks_node_group.k8simp13-ng.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "k8simp13-ng"
  }
}
