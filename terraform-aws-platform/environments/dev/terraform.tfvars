aws_region  = "ap-south-1"
environment = "dev"

vpc_cidr             = "10.10.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]

ssh_cidr       = "183.82.251.11/32" # your public IP
instance_count = 1
instance_type  = "t3.micro"
key_name       = "DevOps"
