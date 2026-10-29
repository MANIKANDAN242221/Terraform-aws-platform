terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment after running ../../bootstrap to store state in S3
  # backend "s3" {
  #   bucket       = "<your-state-bucket>"
  #   key          = "prod/terraform.tfstate"
  #   region       = "ap-south-1"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# VPC: 2 public subnets, 2 private subnets, IGW, NAT
module "vpc" {
  source = "../../modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# Security Group: allow 22, 80, 443
module "security_group" {
  source = "../../modules/security-groups"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  ssh_cidr    = var.ssh_cidr

  depends_on = [module.vpc]
}

# Public EC2 instances
module "ec2" {
  source = "../../modules/ec2"

  environment       = var.environment
  instance_count    = var.instance_count
  instance_type     = var.instance_type
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_group.public_sg_id
  key_name          = var.key_name
  user_data         = file("${path.module}/../../web/user_data.sh")

  # Wait for IGW, NAT and route tables so user_data can reach the internet
  depends_on = [module.vpc, module.security_group]
}

# Static website: private S3 bucket served through CloudFront
module "s3_website" {
  source = "../../modules/s3-website"

  environment = var.environment
  source_dir  = "${path.module}/../../web"
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  environment                 = var.environment
  bucket_id                   = module.s3_website.bucket_id
  bucket_arn                  = module.s3_website.bucket_arn
  bucket_regional_domain_name = module.s3_website.bucket_regional_domain_name
}
