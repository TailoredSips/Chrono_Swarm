variable "subnet_id" {
  description = "Subnet ID for control nodes"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for control nodes"
  type        = string
}

variable "instance_type" {
  description = "Instance type for control nodes"
  type        = string
  default     = "t4g.medium"
}

variable "security_group_id" {
  description = "Security group ID for control nodes"
  type        = string
}
