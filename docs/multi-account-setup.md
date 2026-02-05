# Multi-Account Setup Guide

## Overview

This guide explains how to configure and deploy VPCs across multiple AWS accounts using AWS SSO profiles.

## Account Configuration

### Current Setup
- **Account 1**: `093285711854` (my-sso-profile)
- **Account 2**: `509507123602` (account2-sso)

### AWS SSO Configuration

#### ~/.aws/config
```ini
[profile my-sso-profile]
sso_session = punctual-bonito
sso_account_id = 093285711854
sso_role_name = AdministratorAccess
region = us-east-1

[profile account2-sso]
sso_session = punctual-bonito1
sso_account_id = 509507123602
sso_role_name = AdministratorAccess
region = us-east-1

[sso-session punctual-bonito]
sso_start_url = https://awsarchitects.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[sso-session punctual-bonito1]
sso_start_url = https://d-90679c150f.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

## Authentication

### Login to Both Accounts
```bash
# Account 1
AWS_PROFILE=my-sso-profile aws sso login --use-device-code

# Account 2
AWS_PROFILE=account2-sso aws sso login --use-device-code
```

### Verify Access
```bash
# Check Account 1
AWS_PROFILE=my-sso-profile aws sts get-caller-identity

# Check Account 2
AWS_PROFILE=account2-sso aws sts get-caller-identity
```

## Deployment Strategies

### Sequential Deployment
```bash
# Deploy Account 1 regions
./scripts/deploy.sh dev-account1-us-east-1 apply
./scripts/deploy.sh dev-account1-us-west-2 apply

# Deploy Account 2 regions
./scripts/deploy.sh dev-account2-us-east-1 apply
./scripts/deploy.sh dev-account2-us-west-2 apply
```

### Parallel Deployment
```bash
# Deploy all accounts and regions simultaneously
for env in dev-account1-us-east-1 dev-account1-us-west-2 dev-account2-us-east-1 dev-account2-us-west-2; do
  ./scripts/deploy.sh $env apply &
done
wait
```

## CIDR Block Management

### Account 1 (093285711854)
- **us-east-1**: 10.0.0.0/16
- **us-west-2**: 10.1.0.0/16

### Account 2 (509507123602)
- **us-east-1**: 10.2.0.0/16
- **us-west-2**: 10.3.0.0/16

## Adding New Accounts

### Step 1: Configure AWS Profile
```bash
# Add to ~/.aws/config
[profile account3-sso]
sso_session = your-sso-session
sso_account_id = NEW_ACCOUNT_ID
sso_role_name = AdministratorAccess
region = us-east-1
```

### Step 2: Create Environment Directories
```bash
mkdir -p environments/{dev-account3-us-east-1,dev-account3-us-west-2}
```

### Step 3: Configure CIDR Blocks
- Ensure non-overlapping CIDR blocks
- Update terraform.tfvars with new ranges

### Step 4: Test and Deploy
```bash
./scripts/deploy.sh dev-account3-us-east-1 plan
./scripts/deploy.sh dev-account3-us-east-1 apply
```

## Troubleshooting

### Common Issues

#### SSO Session Expired
```bash
# Re-authenticate
aws sso login --use-device-code --profile PROFILE_NAME
```

#### Wrong Account ID in Output
- Ensure correct profile is specified in terraform.tfvars
- Verify provider configuration uses profile variable

#### CIDR Conflicts
- Check for overlapping CIDR blocks across accounts
- Update VPC and subnet CIDRs to use unique ranges

### Debug Commands
```bash
# Check current AWS identity
aws sts get-caller-identity --profile PROFILE_NAME

# Validate Terraform configuration
terraform validate

# Check which profile Terraform is using
terraform plan -var-file="terraform.tfvars" | grep "account_id"
```
