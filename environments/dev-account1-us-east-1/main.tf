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

module "eks" {
  source = "../../modules/eks"

  cluster_name                            = var.enable_eks ? var.cluster_name : ""
  cluster_version                         = var.enable_eks ? var.cluster_version : "1.33"
  vpc_id                                  = module.vpc.vpc_id
  subnet_ids                              = var.enable_eks ? concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids) : []
  private_subnet_ids                      = var.enable_eks ? module.vpc.private_subnet_ids : []
  cluster_endpoint_private_access         = var.enable_eks ? var.cluster_endpoint_private_access : false
  cluster_endpoint_public_access          = var.enable_eks ? var.cluster_endpoint_public_access : true
  cluster_endpoint_public_access_cidrs    = var.enable_eks ? var.cluster_endpoint_public_access_cidrs : ["0.0.0.0/0"]
  cluster_service_ipv4_cidr               = var.enable_eks ? var.cluster_service_ipv4_cidr : null
  cluster_enabled_log_types               = var.enable_eks ? var.cluster_enabled_log_types : []
  cloudwatch_log_group_retention_in_days  = var.enable_eks ? var.cloudwatch_log_group_retention_in_days : 7
  cluster_addons                          = var.enable_eks ? var.cluster_addons : {}
  enable_irsa                             = var.enable_eks ? true : false
  enable_node_groups                      = var.enable_eks ? var.enable_node_groups : false
  node_groups                             = var.enable_eks ? var.node_groups : {}
  enable_monitoring                       = var.enable_eks ? var.enable_monitoring : false
  environment                             = var.enable_eks ? var.environment : ""

  access_config = var.enable_eks ? {
    bootstrap_cluster_creator_admin_permissions = false
    authentication_mode                         = "API_AND_CONFIG_MAP"
  } : null

  tags = var.common_tags
}
