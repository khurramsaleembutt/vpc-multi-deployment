# Troubleshooting Guide

## Common Issues and Solutions

### 1. AWS Authentication Issues

#### SSO Session Expired
**Symptoms:**
```
Error: failed to refresh cached credentials, no cached token present
```

**Solution:**
```bash
# Re-authenticate with device code (headless mode)
aws sso login --use-device-code --profile my-sso-profile
aws sso login --use-device-code --profile account2-sso
```

#### Wrong Account ID in Outputs
**Symptoms:**
- Tags show correct account ID
- Terraform output shows wrong account ID

**Root Cause:** `data.aws_caller_identity` not using correct provider

**Solution:**
```hcl
# Ensure data source uses correct provider
data "aws_caller_identity" "current" {
  provider = aws.primary  # For multi-region setups
}
```

### 2. Resource Naming Conflicts

#### Duplicate Resource Names
**Symptoms:**
- Resources with same names across environments

**Solution:**
- Use unique environment names in terraform.tfvars
- Include account and region in resource tags

### 3. Network Configuration Issues

#### CIDR Block Conflicts
**Solution:**
```bash
# Use non-overlapping CIDR blocks
# Account 1: 10.0.0.0/16, 10.1.0.0/16
# Account 2: 10.2.0.0/16, 10.3.0.0/16
```

## Debug Commands

### Check AWS Configuration
```bash
# Check current identity
aws sts get-caller-identity --profile PROFILE_NAME

# Validate configuration
terraform validate
terraform plan -var-file="terraform.tfvars"
```
