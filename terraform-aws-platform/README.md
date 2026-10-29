# terraform-aws-platform

AWS platform with three environments (`dev`, `staging`, `prod`), each built from these modules:

| Module | Creates |
|---|---|
| `modules/vpc` | VPC, Internet Gateway, 2 public + 2 private subnets (2 AZs), 1 NAT gateway, route tables |
| `modules/security-groups` | Public-instance SG: inbound 22 (SSH), 80 (HTTP), 443 (HTTPS); all outbound |
| `modules/ec2` | Public web instances (Amazon Linux 2023 + nginx) in the public subnets |
| `modules/s3-website` | Private S3 bucket with the static site from `web/` |
| `modules/cloudfront` | CloudFront distribution (OAC, default certificate, no WAF) in front of the bucket |

| | dev | staging | prod |
|---|---|---|---|
| VPC CIDR | 10.10.0.0/16 | 10.20.0.0/16 | 10.30.0.0/16 |
| Public subnets | 10.10.1.0/24, 10.10.2.0/24 | 10.20.1.0/24, 10.20.2.0/24 | 10.30.1.0/24, 10.30.2.0/24 |
| Private subnets | 10.10.11.0/24, 10.10.12.0/24 | 10.20.11.0/24, 10.20.12.0/24 | 10.30.11.0/24, 10.30.12.0/24 |
| NAT gateways | 1 | 1 | 1 |
| Web instances | 1 | 2 | 2 |
| CI apply | on push to `main` | on push to `main` | manual only (`workflow_dispatch`) |

## Usage

```bash
# 1. (optional) remote state - once per account
cd bootstrap && terraform init && terraform apply
# then uncomment the backend "s3" block in environments/<env>/main.tf

# 2. deploy an environment
cd environments/dev            # or environments/staging
cp terraform.tfvars.example terraform.tfvars   # set ssh_cidr + key_name
terraform init
terraform plan
terraform apply

terraform output instance_public_ips   # open http://<ip>

# 3. tear down
terraform destroy
```

Notes:
- **Cost:** the NAT gateway is billed hourly, so run `terraform destroy` when you're done.
- **SSH:** `ssh_cidr` defaults to `0.0.0.0/0`. Set it to your own `/32`.
- **HTTPS:** port 443 is open in the security group, but nginx only serves HTTP (80) until you add a certificate.
- The startup script is `web/user_data.sh`.

---

## Scaffold commands

# Create folders
mkdir -p terraform-aws-platform/{bootstrap,modules/{vpc,security-groups,ec2},environments/{dev,staging},web,.github/workflows}

# Bootstrap files
touch terraform-aws-platform/bootstrap/{main.tf,variables.tf,outputs.tf}

# VPC module files
touch terraform-aws-platform/modules/vpc/{main.tf,variables.tf,outputs.tf}

# Security Groups module files
touch terraform-aws-platform/modules/security-groups/{main.tf,variables.tf,outputs.tf}

# EC2 module files
touch terraform-aws-platform/modules/ec2/{main.tf,variables.tf,outputs.tf}

# Dev environment files
touch terraform-aws-platform/environments/dev/{main.tf,variables.tf,outputs.tf,terraform.tfvars.example}

# Staging environment files
touch terraform-aws-platform/environments/staging/{main.tf,variables.tf,outputs.tf,terraform.tfvars.example}

# Web files
touch terraform-aws-platform/web/{index.html,nginx.conf}

# GitHub Actions file
touch terraform-aws-platform/.github/workflows/terraform-check.yml

# Root files
touch terraform-aws-platform/.gitignore
touch terraform-aws-platform/README.md