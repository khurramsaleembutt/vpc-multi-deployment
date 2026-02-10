# Single Region VPC Deployment - Account 1, us-east-1
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Single Region Provider
provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = var.common_tags
  }
}

# VPC in Single Region
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnets
  private_subnet_cidrs = var.private_subnets
  enable_nat_gateway   = var.enable_nat_gateway

  environment  = var.environment
  project_name = var.project_name
  common_tags  = var.common_tags
}
