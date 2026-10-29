variable "environment" {
  description = "Environment name (dev / staging)"
  type        = string
}

variable "instance_count" {
  description = "Number of public instances"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_ids" {
  description = "Public subnet IDs to launch instances in"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the instances"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
  default     = null
}

variable "user_data" {
  description = "Startup script"
  type        = string
  default     = null
}
