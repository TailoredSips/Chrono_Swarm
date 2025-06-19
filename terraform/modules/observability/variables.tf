variable "alert_sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}
