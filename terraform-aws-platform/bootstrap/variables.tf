variable "aws_region" {
  description = "AWS region for the state bucket."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short project name, used as a prefix for resource names."
  type        = string
  default     = "terraform-aws-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-32 chars of lowercase letters, digits and hyphens."
  }
}

variable "state_bucket_name" {
  description = "Override for the state bucket name. Leave null to use <project>-tfstate-<account_id>-<region>."
  type        = string
  default     = null
}

variable "environments" {
  description = "Environments that will store state in this bucket (used to render backend configs)."
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "noncurrent_version_retention_days" {
  description = "Days to keep old (noncurrent) state file versions."
  type        = number
  default     = 90
}

variable "create_dynamodb_lock_table" {
  description = "Create a DynamoDB lock table. Only needed for Terraform < 1.10; newer versions lock in S3 with use_lockfile."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow deleting the bucket even if it contains state. Keep false outside of throwaway accounts."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags applied to all resources."
  type        = map(string)
  default     = {}
}
