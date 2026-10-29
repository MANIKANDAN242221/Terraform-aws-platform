# Lets CloudFront sign requests to the private S3 bucket
resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.environment}-site-oac"
  description                       = "OAC for ${var.bucket_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# AWS managed cache policy
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.environment} website"
  default_root_object = var.default_root_object
  price_class         = var.price_class

  # null = "Do not enable security protections" (no WAF)
  web_acl_id = var.web_acl_id

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-${var.bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.optimized.id
    compress               = true
  }

  # S3 returns 403 for missing keys (no ListBucket), so map both to the error page
  dynamic "custom_error_response" {
    for_each = var.error_document == null ? [] : [403, 404]
    content {
      error_code         = custom_error_response.value
      response_code      = 404
      response_page_path = "/${var.error_document}"
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Default *.cloudfront.net certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.environment}-website"
  }
}

# Bucket policy lives here (not in the s3 module) because it needs the
# distribution ARN - keeps the two modules free of a dependency cycle.
resource "aws_s3_bucket_policy" "site" {
  bucket = var.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontRead"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${var.bucket_arn}/*"
        Condition = {
          StringEquals = { "AWS:SourceArn" = aws_cloudfront_distribution.site.arn }
        }
      }
    ]
  })
}
