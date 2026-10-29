variable "environment" {
  description = "Environment name (dev / staging)"
  type        = string
}

variable "bucket_name" {
  description = "Override for the bucket name. Leave null to use <environment>-website-<account_id>."
  type        = string
  default     = null
}

variable "source_dir" {
  description = "Local folder with the website files"
  type        = string
}

variable "file_pattern" {
  description = "Glob of files to upload from source_dir"
  type        = string
  default     = "**/*.{html,css,js,json,png,jpg,jpeg,gif,svg,ico,webp,txt,woff,woff2}"
}

variable "force_destroy" {
  description = "Delete the bucket on destroy even if it still has objects"
  type        = bool
  default     = false
}
