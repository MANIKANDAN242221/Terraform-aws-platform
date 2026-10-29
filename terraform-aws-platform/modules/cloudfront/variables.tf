variable "environment" {
  description = "Environment name (dev / staging)"
  type        = string
}

variable "bucket_id" {
  description = "Name of the S3 bucket holding the website"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket holding the website"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "Object returned for requests to /"
  type        = string
  default     = "index.html"
}

variable "error_document" {
  description = "Page shown for 403/404 (e.g. error.html). null = CloudFront default error."
  type        = string
  default     = null
}

variable "price_class" {
  description = "PriceClass_100, PriceClass_200 (includes India) or PriceClass_All"
  type        = string
  default     = "PriceClass_200"
}

variable "web_acl_id" {
  description = "WAF web ACL ARN. null = security protections disabled."
  type        = string
  default     = null
}
