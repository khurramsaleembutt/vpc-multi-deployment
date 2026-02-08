# Account 1 us-west-2 Configuration
aws_profile = "my-sso-profile"
region      = "us-west-2"

# Environment
environment  = "dev-acc1-west"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.1.0.0/16"

# Subnet Configuration
public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets = ["10.1.10.0/24", "10.1.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc1-west"
  Account     = "093285711854"
  Region      = "us-west-2"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
