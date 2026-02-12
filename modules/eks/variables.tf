variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.33"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "Service IPv4 CIDR for the cluster"
  type        = string
  default     = "172.20.0.0/16"
}

variable "cluster_ip_family" {
  description = "IP family used to assign Kubernetes pod and service addresses"
  type        = string
  default     = "ipv4"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Enable cluster creator admin permissions"
  type        = bool
  default     = true
}

variable "authentication_mode" {
  description = "Authentication mode for the cluster"
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "access_config" {
  description = "Access configuration for the cluster"
  type = object({
    bootstrap_cluster_creator_admin_permissions = bool
    authentication_mode                         = string
  })
  default = {
    bootstrap_cluster_creator_admin_permissions = true
    authentication_mode                         = "API_AND_CONFIG_MAP"
  }
}

variable "cluster_addons" {
  description = "Map of cluster addon configurations"
  type = map(object({
    version                      = string
    resolve_conflicts_on_create  = string
    resolve_conflicts_on_update  = string
    service_account_role_arn     = string
  }))
  default = {}
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "cluster_enabled_log_types" {
  description = "List of control plane logging to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events"
  type        = number
  default     = 7
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "KMS Key ID to use for encrypting CloudWatch logs"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
