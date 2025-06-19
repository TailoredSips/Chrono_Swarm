output "control_asg_id" {
  description = "The Auto Scaling Group ID for control nodes"
  value       = aws_autoscaling_group.control_nodes.id
}
