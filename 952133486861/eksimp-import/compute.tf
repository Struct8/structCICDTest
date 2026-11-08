resource "aws_autoscaling_traffic_source_attachment" "eksimp-tg_to_eksimp-ng" {
  autoscaling_group_name = aws_eks_node_group.eksimp-ng.resources[0].autoscaling_groups[0].name
  traffic_source {
    identifier = aws_lb_target_group.eksimp-tg.arn
    type       = "elbv2"
  }
}
