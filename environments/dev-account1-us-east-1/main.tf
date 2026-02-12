# Single Region VPC Deployment - Account 1, us-east-1
# Production-Grade Multi-Account VPC Deployment
# Testing SARIF upload with proper permissions and destroy workflow fix
# GitOps rollback demo completed - pipeline should now pass

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

# EKS Module
module "eks" {
  count  = var.enable_eks ? 1 : 0
  source = "../../modules/eks"

  cluster_name                            = var.cluster_name
  cluster_version                         = var.cluster_version
  vpc_id                                  = module.vpc.vpc_id
  subnet_ids                              = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  private_subnet_ids                      = module.vpc.private_subnet_ids
  cluster_endpoint_private_access         = var.cluster_endpoint_private_access
  cluster_endpoint_public_access          = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs    = var.cluster_endpoint_public_access_cidrs
  cluster_service_ipv4_cidr               = var.cluster_service_ipv4_cidr
  cluster_enabled_log_types               = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days  = var.cloudwatch_log_group_retention_in_days
  cluster_addons                          = var.cluster_addons
  enable_irsa                             = true
  enable_node_groups                      = var.enable_node_groups
  node_groups                             = var.node_groups

  access_config = {
    bootstrap_cluster_creator_admin_permissions = false
    authentication_mode                         = "API_AND_CONFIG_MAP"
  }

  tags = var.common_tags
}
