variable "region" {
  description = "AWS region for Packer builds"
  type        = string
  default     = "us-west-2"
}

variable "ami_name_prefix" {
  description = "Prefix for AMI names"
  type        = string
  default     = "chrono-swarm-"
}
