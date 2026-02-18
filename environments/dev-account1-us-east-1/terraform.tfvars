# Account 1 us-east-1 Configuration
aws_profile = "my-sso-profile"
region      = "us-east-1"

# Environment
environment  = "Dev"
project_name = "multi-vpc"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Subnet Configuration
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

# Features - ENABLED FOR ECOMMERCEAPP
enable_nat_gateway = true

# EKS Configuration
enable_eks = true
cluster_name = "ecommerce-dev-cluster"
cluster_version = "1.33"
cluster_endpoint_private_access = true
cluster_endpoint_public_access = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
cluster_service_ipv4_cidr = "172.20.0.0/16"
cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cloudwatch_log_group_retention_in_days = 7

# EKS Addons
cluster_addons = {
  coredns = {
    version = "v1.11.3-eksbuild.2"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = ""
  }
  kube-proxy = {
    version = "v1.33.0-eksbuild.2"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = ""
  }
  vpc-cni = {
    version = "v1.19.0-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = ""
  }
  eks-pod-identity-agent = {
    version = "v1.3.4-eksbuild.1"
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "OVERWRITE"
    service_account_role_arn = ""
  }
}

# Node Groups
enable_node_groups = true
node_groups = {
  main = {
    instance_types = ["t3.small"]
    capacity_type  = "ON_DEMAND"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    disk_size     = 20
    ami_type      = "AL2023_x86_64_STANDARD"
    subnet_ids    = []  # Will use private subnets from VPC by default
    labels = {
      Environment = "dev"
      NodeGroup   = "main"
    }
    taints = []
  }
}

# Monitoring Configuration
enable_monitoring = true

# Tags
common_tags = {
  Project     = "multi-vpc-deployment"
  Environment = "Dev"
  Service     = "infrastructure"
  Account     = "093285711854"
  Region      = "us-east-1"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}
