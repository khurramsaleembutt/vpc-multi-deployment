# Account 2 us-east-1 Configuration
aws_profile = "account2-sso"
region      = "us-east-1"

# Environment
environment  = "dev-acc2-east"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.2.0.0/16"

# Subnet Configuration
public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnets = ["10.2.10.0/24", "10.2.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc2-east"
  Account     = "509507123602"
  Region      = "us-east-1"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
