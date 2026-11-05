resource "aws_cloudwatch_metric_alarm" "hub-cpu-high" {
  # ajuste manual · dimensions — The ASG->alarm connection did not generate the alarm dimensions in HCL, so the alarm would watch account-wide CPU instead of this ASG. Pin it to the Hub ASG.
  # ajuste manual · alarm_actions — The alarm->autoscaling_policy connection did not generate alarm_actions in HCL, so the step scaling policy would never fire. Point the alarm at the step policy ARN so CPU>80% triggers the +2 step scale-out.
  alarm_name          = "hub-cpu-high"
  metric_name         = "CPUUtilization"
  alarm_actions       = [aws_autoscaling_policy.cpu-spike-step.arn]
  alarm_description   = "CPU > 80% on the Hub ASG for 2 minutes. It fires the cpu-spike-step step scaling policy (+2 instances at once) for a fast reaction to spikes, on top of the smoother target-tracking policies. Dimensions and alarm_actions are set via overrides (the ASG->alarm and alarm->policy connections did not generate them). NOTE: this alarm's metric is AWS/EC2 CPUUtilization aggregated by the ASG dimension."
  comparison_operator = "GreaterThanThreshold"
  dimensions          = { AutoScalingGroupName = aws_autoscaling_group.hub-asg-mixed.name }
  evaluation_periods  = 2
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  tags = {
    Name           = "hub-cpu-high"
    State          = "loadtest-asg-mixed"
    Struct8Creator = "rmay struct"
  }
}
