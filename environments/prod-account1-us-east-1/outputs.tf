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
