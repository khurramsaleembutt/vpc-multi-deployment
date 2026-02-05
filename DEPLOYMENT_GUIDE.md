# Multi-Account Multi-Region Deployment Guide

## 🆓 FREE Resources Only
- ✅ VPC (Free)
- ✅ Subnets (Free) 
- ✅ Internet Gateway (Free)
- ✅ Route Tables (Free)
- ✅ Security Groups (Free)
- ❌ NAT Gateway (DISABLED - $45/month)
- ❌ Elastic IPs (DISABLED - $7/month)

**Total Cost: $0.00** 

## 🌍 Step-by-Step Multi-Region Deployment

### Step 1: Local Development - Single Account, Multiple Regions

```bash
cd /home/ubuntu/terraform_project/vpc-multi-deployment

# 1. Plan deployment (safe - no cost)
./scripts/deploy.sh dev plan

# 2. Apply deployment (creates FREE resources only)
./scripts/deploy.sh dev apply

# 3. View results
./scripts/deploy.sh dev output
```

**Result**: Creates VPCs in us-east-1 AND us-west-2 simultaneously

### Step 2: Multi-Account Setup (Local)

#### Configure Multiple AWS Profiles:
```bash
# ~/.aws/config
[profile account-dev]
sso_start_url = https://your-org.awsapps.com/start
sso_region = us-east-1
sso_account_id = 111111111111
sso_role_name = AdministratorAccess

[profile account-staging] 
sso_account_id = 222222222222
sso_role_name = AdministratorAccess

[profile account-prod]
sso_account_id = 333333333333
sso_role_name = AdministratorAccess
```

#### Deploy to Multiple Accounts:
```bash
# Account 1 (Dev)
sed -i 's/aws_profile = .*/aws_profile = "account-dev"/' environments/dev/terraform.tfvars
./scripts/deploy.sh dev apply

# Account 2 (Staging) 
sed -i 's/aws_profile = .*/aws_profile = "account-staging"/' environments/dev/terraform.tfvars
./scripts/deploy.sh dev apply

# Account 3 (Prod)
sed -i 's/aws_profile = .*/aws_profile = "account-prod"/' environments/dev/terraform.tfvars
./scripts/deploy.sh dev apply
```

**Result**: Same VPC deployed across 3 accounts × 2 regions = 6 VPCs total

## 🚀 Pipeline-Based Multi-Account Deployment

### Step 1: Setup GitHub Repository
```bash
# Initialize git repo
cd /home/ubuntu/terraform_project/vpc-multi-deployment
git init
git add .
git commit -m "Initial multi-region VPC setup"
git remote add origin https://github.com/YOUR-USERNAME/vpc-multi-deployment.git
git push -u origin main
```

### Step 2: Configure GitHub Secrets
```bash
# In GitHub repo → Settings → Secrets and variables → Actions

# Add these secrets:
AWS_ROLE_ARN_DEV_ACCOUNT     = "arn:aws:iam::111111111111:role/GitHubActionsRole"
AWS_ROLE_ARN_STAGING_ACCOUNT = "arn:aws:iam::222222222222:role/GitHubActionsRole"  
AWS_ROLE_ARN_PROD_ACCOUNT    = "arn:aws:iam::333333333333:role/GitHubActionsRole"
```

### Step 3: Create Cross-Account IAM Roles
```bash
# In each AWS account, create IAM role:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
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

### Step 4: Trigger Pipeline Deployment
```bash
# Method 1: Push to main branch
git push origin main
# → Automatically deploys to dev account

# Method 2: Manual dispatch (GitHub UI)
# Go to: Actions → Multi-Region VPC Deployment → Run workflow
# Select: environment=dev, action=apply

# Method 3: GitHub CLI
gh workflow run deploy.yml -f environment=dev -f action=apply
```

## 🎯 Deployment Matrix

### Pipeline Deployment Results:
| Account | Region | VPC CIDR | Status |
|---------|--------|----------|---------|
| Dev | us-east-1 | 10.0.0.0/16 | ✅ Deployed |
| Dev | us-west-2 | 10.1.0.0/16 | ✅ Deployed |
| Staging | us-east-1 | 10.0.0.0/16 | ✅ Deployed |
| Staging | us-west-2 | 10.1.0.0/16 | ✅ Deployed |
| Prod | us-east-1 | 10.0.0.0/16 | ✅ Deployed |
| Prod | us-west-2 | 10.1.0.0/16 | ✅ Deployed |

**Total: 6 VPCs across 3 accounts × 2 regions**

## 🔄 Testing Workflow

### Local Testing:
```bash
# 1. Test single region
./scripts/deploy.sh dev plan

# 2. Test multi-region  
./scripts/deploy.sh dev apply

# 3. Verify outputs
aws ec2 describe-vpcs --profile my-sso-profile --region us-east-1
aws ec2 describe-vpcs --profile my-sso-profile --region us-west-2
```

### Pipeline Testing:
```bash
# 1. Create PR → Triggers plan for all environments
git checkout -b test-deployment
git push origin test-deployment
# → Creates PR → Runs terraform plan

# 2. Merge PR → Triggers apply for dev
git checkout main
git merge test-deployment
git push origin main
# → Deploys to dev account

# 3. Manual multi-account deployment
gh workflow run deploy.yml -f environment=dev -f action=apply
# → Deploys to all 3 accounts
```

## 🧹 Cleanup
```bash
# Local cleanup
./scripts/deploy.sh dev destroy

# Pipeline cleanup  
gh workflow run deploy.yml -f environment=dev -f action=destroy
```

**Ready to test? Start with Step 1 - it's completely free!**
