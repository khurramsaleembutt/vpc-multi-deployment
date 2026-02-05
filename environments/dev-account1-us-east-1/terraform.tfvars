# Account 1 us-east-1 Configuration
aws_profile = "my-sso-profile"
region = "us-east-1"

# Environment
environment  = "dev-acc1-east"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Subnet Configuration
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc1-east"
  Account     = "093285711854"
  Region      = "us-east-1"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
