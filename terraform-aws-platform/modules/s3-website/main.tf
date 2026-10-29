data "aws_caller_identity" "current" {}

locals {
  # Bucket names are global, so suffix with the account ID
  bucket_name = coalesce(var.bucket_name, "${var.environment}-website-${data.aws_caller_identity.current.account_id}")

  files = fileset(var.source_dir, var.file_pattern)

  content_types = {
    ".html"  = "text/html"
    ".css"   = "text/css"
    ".js"    = "application/javascript"
    ".json"  = "application/json"
    ".png"   = "image/png"
    ".jpg"   = "image/jpeg"
    ".jpeg"  = "image/jpeg"
    ".gif"   = "image/gif"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".webp"  = "image/webp"
    ".txt"   = "text/plain"
    ".woff"  = "font/woff"
    ".woff2" = "font/woff2"
  }
}

# Private bucket - only CloudFront can read it (policy lives in the cloudfront module)
resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name = local.bucket_name
  }
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload the website files
resource "aws_s3_object" "site" {
  for_each = local.files

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${var.source_dir}/${each.value}"
  source_hash  = filemd5("${var.source_dir}/${each.value}")
  content_type = lookup(local.content_types, lower(try(regex("\\.[^.]+$", each.value), "")), "application/octet-stream")
}
