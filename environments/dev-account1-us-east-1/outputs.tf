output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# Summary Output with Account Information
output "deployment_summary" {
  description = "Summary of VPC deployment with account details"
  value = {
    account_id      = data.aws_caller_identity.current.account_id
    region          = var.region
    vpc_id          = module.vpc.vpc_id
    environment     = var.environment
    project         = var.project_name
    aws_profile     = var.aws_profile
    deployment_time = timestamp()
  }
}
# EKS Outputs
output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = var.enable_eks ? module.eks[0].cluster_id : null
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = var.enable_eks ? module.eks[0].cluster_arn : null
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = var.enable_eks ? module.eks[0].cluster_endpoint : null
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = var.enable_eks ? module.eks[0].cluster_version : null
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = var.enable_eks ? module.eks[0].cluster_oidc_issuer_url : null
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = var.enable_eks ? module.eks[0].cluster_certificate_authority_data : null
  sensitive   = true
}
