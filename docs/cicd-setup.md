# CI/CD Pipeline Configuration

## Overview

This document explains how to set up automated CI/CD pipelines for multi-account, multi-region VPC deployments using GitHub Actions.

## Pipeline Architecture

### Deployment Matrix
- **Accounts**: 2 (093285711854, 509507123602)
- **Regions**: 2 per account (us-east-1, us-west-2)
- **Total Deployments**: 4 VPCs

### Workflow Triggers
- **Pull Request**: Runs `terraform plan` for all environments
- **Push to main**: Runs `terraform apply` for dev environments
- **Manual dispatch**: Deploy to specific environments

## GitHub Actions Setup

### Required Secrets
```bash
# In GitHub repo → Settings → Secrets and variables → Actions
AWS_ROLE_ARN_ACCOUNT1 = "arn:aws:iam::093285711854:role/GitHubActionsRole"
AWS_ROLE_ARN_ACCOUNT2 = "arn:aws:iam::509507123602:role/GitHubActionsRole"
```

### Workflow Configuration
```yaml
name: Multi-Account VPC Deployment

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
        - dev-account1-us-east-1
        - dev-account1-us-west-2
        - dev-account2-us-east-1
        - dev-account2-us-west-2

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    
    strategy:
      matrix:
        environment: 
          - dev-account1-us-east-1
          - dev-account1-us-west-2
          - dev-account2-us-east-1
          - dev-account2-us-west-2
    
    steps:
    - uses: actions/checkout@v4
    - uses: hashicorp/setup-terraform@v3
    
    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: ${{ secrets[format('AWS_ROLE_ARN_ACCOUNT{0}', matrix.environment contains 'account1' && '1' || '2')] }}
        aws-region: ${{ matrix.environment contains 'east' && 'us-east-1' || 'us-west-2' }}
    
    - name: Terraform Plan
      working-directory: ./environments/${{ matrix.environment }}
      run: |
        terraform init
        terraform plan -var-file="terraform.tfvars"
```

## Cross-Account IAM Roles

### Account 1 (093285711854)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::093285711854:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-USERNAME/vpc-multi-deployment:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### Account 2 (509507123602)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::509507123602:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR-USERNAME/vpc-multi-deployment:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

## Deployment Strategies

### Parallel Deployment
```yaml
jobs:
  deploy-all-regions:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - environment: dev-account1-us-east-1
            account: account1
            region: us-east-1
          - environment: dev-account1-us-west-2
            account: account1
            region: us-west-2
          - environment: dev-account2-us-east-1
            account: account2
            region: us-east-1
          - environment: dev-account2-us-west-2
            account: account2
            region: us-west-2
```

### Sequential Deployment
```yaml
jobs:
  deploy-account1:
    runs-on: ubuntu-latest
    steps:
      # Deploy account1 regions sequentially
  
  deploy-account2:
    runs-on: ubuntu-latest
    needs: deploy-account1
    steps:
      # Deploy account2 regions after account1
```

## Manual Triggers

### GitHub CLI
```bash
# Deploy specific environment
gh workflow run deploy.yml -f environment=dev-account1-us-east-1

# Deploy all environments
gh workflow run deploy.yml
```

### GitHub UI
1. Go to Actions tab
2. Select "Multi-Account VPC Deployment"
3. Click "Run workflow"
4. Select environment and action

## Monitoring and Notifications

### Slack Integration
```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: "VPC deployment ${{ job.status }} for ${{ matrix.environment }}"
```

### Cost Monitoring
```yaml
- name: Run Infracost
  run: |
    infracost breakdown --path . --format json --out-file infracost.json
    infracost comment github --path infracost.json --repo $GITHUB_REPOSITORY --pull-request $PR_NUMBER
```

## Best Practices

1. **Use environment protection rules** for production deployments
2. **Implement approval workflows** for critical environments
3. **Store sensitive data in GitHub Secrets**
4. **Use matrix strategies** for parallel deployments
5. **Implement proper error handling** and rollback procedures
