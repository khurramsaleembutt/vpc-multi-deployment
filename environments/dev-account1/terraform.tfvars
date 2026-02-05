# Account 1 Dev Environment Configuration  
aws_profile = "my-sso-profile"

# Regions
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Environment
environment  = "dev-acc1"
project_name = "multi-vpc"

# VPC Configuration
primary_vpc_cidr   = "10.0.0.0/16"
secondary_vpc_cidr = "10.1.0.0/16"

# Subnet Configuration
primary_public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
primary_private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

secondary_public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
secondary_private_subnets = ["10.1.10.0/24", "10.1.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc1"
  Account     = "093285711854"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
