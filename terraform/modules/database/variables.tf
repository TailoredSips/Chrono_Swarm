variable "db_instance_class" {
  description = "DB instance class"
  type        = string
  default     = "db.t4g.medium"
}

variable "db_username" {
  description = "DB username"
  type        = string
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "chrono"
}

variable "db_security_group_id" {
  description = "Security group ID for DB"
  type        = string
}

variable "db_subnet_group" {
  description = "DB subnet group name"
  type        = string
}
