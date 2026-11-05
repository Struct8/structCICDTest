resource "aws_cloudwatch_metric_alarm" "hub-cpu-high" {
  alarm_name          = "hub-cpu-high"
  metric_name         = "CPUUtilization"
  alarm_actions       = [aws_autoscaling_policy.cpu-spike-step.arn]
  alarm_description   = "CPU > 80% on the Hub ASG for 2 minutes. It fires the cpu-spike-step step scaling policy (+2 instances at once) for a fast reaction to spikes, on top of the smoother target-tracking policies. Dimensions and alarm_actions are set via overrides (the ASG->alarm and alarm->policy connections did not generate them). NOTE: this alarm's metric is AWS/EC2 CPUUtilization aggregated by the ASG dimension."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hub-asg-mixed.name
  }
  tags = {
    Name           = "hub-cpu-high"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}
