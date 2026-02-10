# Production Account 1 us-east-1 Configuration
aws_profile = "my-sso-profile"
region      = "us-east-1"

# Environment
environment  = "Prod"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.100.0.0/16"

# Subnet Configuration
public_subnets  = ["10.100.1.0/24", "10.100.2.0/24"]
private_subnets = ["10.100.10.0/24", "10.100.20.0/24"]

# Features - DISABLED FOR COST SAVINGS
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "Prod"
  Service     = "infrastructure"
  Account     = "093285711854"
  Region      = "us-east-1"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
