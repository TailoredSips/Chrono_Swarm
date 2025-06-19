variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "bastion_ami" {
  description = "AMI for bastion host"
  type        = string
}

variable "bastion_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t4g.nano"
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "key_name" {
  description = "SSH key name for bastion host"
  type        = string
}
