output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "security_group_id" {
  value = module.security_group.public_sg_id
}

output "instance_public_ips" {
  value = module.ec2.public_ips
}

output "website_bucket" {
  value = module.s3_website.bucket_id
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "website_url" {
  value = "https://${module.cloudfront.domain_name}"
}
