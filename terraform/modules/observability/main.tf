resource "aws_cloudwatch_log_group" "main" {
  name              = "/chrono-swarm/logs"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors high CPU utilization"
  actions_enabled     = true
  alarm_actions       = [var.alert_sns_topic_arn]
  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}
