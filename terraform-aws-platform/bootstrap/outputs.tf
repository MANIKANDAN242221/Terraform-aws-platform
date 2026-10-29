output "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state."
  value       = aws_s3_bucket.state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.state.arn
}

output "aws_region" {
  description = "Region of the state bucket."
  value       = var.aws_region
}

output "dynamodb_lock_table_name" {
  description = "DynamoDB lock table name (null when S3 native locking is used)."
  value       = one(aws_dynamodb_table.lock[*].name)
}

output "backend_configs" {
  description = "Ready-to-paste backend blocks for each environment."
  value = {
    for env in var.environments : env => <<-EOT
      terraform {
        backend "s3" {
          bucket       = "${aws_s3_bucket.state.id}"
          key          = "${env}/terraform.tfstate"
          region       = "${var.aws_region}"
          encrypt      = true
          ${var.create_dynamodb_lock_table ? "dynamodb_table = \"${aws_dynamodb_table.lock[0].name}\"" : "use_lockfile = true"}
        }
      }
    EOT
  }
}
