# Primary Region Outputs
output "primary_vpc_id" {
  description = "ID of the primary VPC"
  value       = module.vpc_primary.vpc_id
}

output "primary_public_subnet_ids" {
  description = "IDs of primary region public subnets"
  value       = module.vpc_primary.public_subnet_ids
}

output "primary_private_subnet_ids" {
  description = "IDs of primary region private subnets"
  value       = module.vpc_primary.private_subnet_ids
}

# Secondary Region Outputs
output "secondary_vpc_id" {
  description = "ID of the secondary VPC"
  value       = module.vpc_secondary.vpc_id
}

output "secondary_public_subnet_ids" {
  description = "IDs of secondary region public subnets"
  value       = module.vpc_secondary.public_subnet_ids
}

output "secondary_private_subnet_ids" {
  description = "IDs of secondary region private subnets"
  value       = module.vpc_secondary.private_subnet_ids
}

# Summary Output with Account Information
output "deployment_summary" {
  description = "Summary of VPC deployment with account details"
  value = {
    account_id       = data.aws_caller_identity.current.account_id
    primary_region   = var.primary_region
    secondary_region = var.secondary_region
    primary_vpc      = module.vpc_primary.vpc_id
    secondary_vpc    = module.vpc_secondary.vpc_id
    environment      = var.environment
    project          = var.project_name
    aws_profile      = var.aws_profile
    deployment_time  = timestamp()
  }
}
