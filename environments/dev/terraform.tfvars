# Original Dev Environment Configuration - Account 1
aws_profile = "my-sso-profile"

# Regions
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Environment
environment  = "dev-original"
project_name = "multi-vpc"

# VPC Configuration - Updated CIDRs to avoid conflicts
primary_vpc_cidr   = "10.4.0.0/16"
secondary_vpc_cidr = "10.5.0.0/16"

# Subnet Configuration
primary_public_subnets  = ["10.4.1.0/24", "10.4.2.0/24"]
primary_private_subnets = ["10.4.10.0/24", "10.4.20.0/24"]

secondary_public_subnets  = ["10.5.1.0/24", "10.5.2.0/24"]
secondary_private_subnets = ["10.5.10.0/24", "10.5.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-original"
  Account     = "093285711854"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
