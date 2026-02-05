# Account 2 us-west-2 Configuration
aws_profile = "account2-sso"
region = "us-west-2"

# Environment
environment  = "dev-acc2-west"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.3.0.0/16"

# Subnet Configuration
public_subnets  = ["10.3.1.0/24", "10.3.2.0/24"]
private_subnets = ["10.3.10.0/24", "10.3.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc2-west"
  Account     = "509507123602"
  Region      = "us-west-2"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
