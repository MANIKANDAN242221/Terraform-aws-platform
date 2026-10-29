variable "environment" {
  description = "Environment name (dev / staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH (use your own IP, e.g. 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0"
}
