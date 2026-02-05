# Account 2 Dev Environment Configuration
aws_profile = "account2-sso"

# Regions  
primary_region   = "us-east-1"
secondary_region = "us-west-2"

# Environment
environment  = "dev-acc2"
project_name = "multi-vpc"

# VPC Configuration (different CIDRs to avoid conflicts)
primary_vpc_cidr   = "10.2.0.0/16"
secondary_vpc_cidr = "10.3.0.0/16"

# Subnet Configuration
primary_public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
primary_private_subnets = ["10.2.10.0/24", "10.2.20.0/24"]

secondary_public_subnets  = ["10.3.1.0/24", "10.3.2.0/24"]
secondary_private_subnets = ["10.3.10.0/24", "10.3.20.0/24"]

# Features - DISABLED FOR FREE TESTING
enable_nat_gateway = false

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "dev-acc2"
  Account     = "509507123602"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
