resource "aws_autoscaling_group" "control_nodes" {
  name                 = "chrono-swarm-control"
  max_size             = 3
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = [var.subnet_id]
  launch_configuration = aws_launch_configuration.control_node.id
}

resource "aws_launch_configuration" "control_node" {
  name_prefix   = "control-node-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  security_groups = [var.security_group_id]
  user_data     = file("${path.module}/scripts/control-node-init.sh")
  lifecycle {
    create_before_destroy = true
  }
}
