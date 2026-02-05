# Multi-Region VPC Deployment - Dev Environment
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary Region (us-east-1)
provider "aws" {
  alias   = "primary"
  region  = var.primary_region
  profile = var.aws_profile

  default_tags {
    tags = var.common_tags
  }
}

# Secondary Region (us-west-2)
provider "aws" {
  alias   = "secondary"
  region  = var.secondary_region
  profile = var.aws_profile

  default_tags {
    tags = var.common_tags
  }
}

# VPC in Primary Region
module "vpc_primary" {
  source = "../../modules/vpc"
  
  providers = {
    aws = aws.primary
  }

  vpc_cidr             = var.primary_vpc_cidr
  public_subnet_cidrs  = var.primary_public_subnets
  private_subnet_cidrs = var.primary_private_subnets
  enable_nat_gateway   = var.enable_nat_gateway
  
  environment   = var.environment
  project_name  = var.project_name
  common_tags   = var.common_tags
}

# VPC in Secondary Region
module "vpc_secondary" {
  source = "../../modules/vpc"
  
  providers = {
    aws = aws.secondary
  }

  vpc_cidr             = var.secondary_vpc_cidr
  public_subnet_cidrs  = var.secondary_public_subnets
  private_subnet_cidrs = var.secondary_private_subnets
  enable_nat_gateway   = var.enable_nat_gateway
  
  environment   = var.environment
  project_name  = var.project_name
  common_tags   = var.common_tags
}
