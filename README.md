# Multi-Region VPC Deployment

Production-grade Terraform module for deploying VPCs across multiple regions and accounts using a modular approach with **separate state files per region**.

## 🏗️ Architecture

```
├── modules/vpc/              # Reusable VPC module
├── environments/             # Environment-specific configurations
│   ├── dev/                 # Original: Multi-region, single state
│   ├── dev-account1/        # Original: Multi-region, single state
│   ├── dev-account2/        # Original: Multi-region, single state
│   ├── dev-account1-us-east-1/  # NEW: Single region, separate state
│   ├── dev-account1-us-west-2/  # NEW: Single region, separate state
│   ├── dev-account2-us-east-1/  # NEW: Single region, separate state
│   └── dev-account2-us-west-2/  # NEW: Single region, separate state
├── scripts/                 # Deployment scripts
├── docs/                    # Documentation
└── .github/workflows/       # CI/CD pipelines
```

## 🎯 State Management Strategy

### **Best Practice: Separate State Per Region**
- ✅ **Independent deployments** (deploy regions separately)
- ✅ **Fault isolation** (one region failure doesn't affect others)
- ✅ **Parallel deployments** (faster CI/CD)
- ✅ **Granular control** (different configurations per region)
- ✅ **Easier rollbacks** (rollback single region)

### **Legacy: Multi-Region Single State**
- Original `dev/`, `dev-account1/`, `dev-account2/` folders
- Kept for comparison and backward compatibility

## 🚀 Quick Start

### **Per-Region Deployment (Recommended)**

```bash
cd /home/ubuntu/terraform_project/vpc-multi-deployment

# Deploy individual regions
./scripts/deploy.sh dev-account1-us-east-1 plan
./scripts/deploy.sh dev-account1-us-east-1 apply

# Deploy all regions in parallel
./scripts/deploy.sh dev-account1-us-east-1 apply &
./scripts/deploy.sh dev-account1-us-west-2 apply &
./scripts/deploy.sh dev-account2-us-east-1 apply &
./scripts/deploy.sh dev-account2-us-west-2 apply &
```

### **Multi-Region Deployment (Legacy)**

```bash
# Deploy to both regions simultaneously (single state)
./scripts/deploy.sh dev-account1 apply
./scripts/deploy.sh dev-account2 apply
```

## 📋 Configuration Matrix

### **Per-Region Deployments**
| Environment | Account | Profile | Region | VPC CIDR | State File |
|-------------|---------|---------|--------|----------|------------|
| dev-account1-us-east-1 | 093285711854 | my-sso-profile | us-east-1 | 10.0.0.0/16 | Separate |
| dev-account1-us-west-2 | 093285711854 | my-sso-profile | us-west-2 | 10.1.0.0/16 | Separate |
| dev-account2-us-east-1 | 509507123602 | account2-sso | us-east-1 | 10.2.0.0/16 | Separate |
| dev-account2-us-west-2 | 509507123602 | account2-sso | us-west-2 | 10.3.0.0/16 | Separate |

### **Multi-Region Deployments (Legacy)**
| Environment | Account | Profile | Regions | VPC CIDRs | State File |
|-------------|---------|---------|---------|-----------|------------|
| dev | 093285711854 | my-sso-profile | us-east-1, us-west-2 | 10.4.0.0/16, 10.5.0.0/16 | Single |
| dev-account1 | 093285711854 | my-sso-profile | us-east-1, us-west-2 | 10.0.0.0/16, 10.1.0.0/16 | Single |
| dev-account2 | 509507123602 | account2-sso | us-east-1, us-west-2 | 10.2.0.0/16, 10.3.0.0/16 | Single |

## 🔄 Deployment Strategies

### **Independent Region Deployment**
```bash
# Deploy only us-east-1 for Account 1
./scripts/deploy.sh dev-account1-us-east-1 apply

# Deploy only us-west-2 for Account 2  
./scripts/deploy.sh dev-account2-us-west-2 apply
```

### **Parallel Multi-Region Deployment**
```bash
# Deploy all 4 regions simultaneously
for env in dev-account1-us-east-1 dev-account1-us-west-2 dev-account2-us-east-1 dev-account2-us-west-2; do
  ./scripts/deploy.sh $env apply &
done
wait
```

### **Account-Based Deployment**
```bash
# Deploy all regions for Account 1
./scripts/deploy.sh dev-account1-us-east-1 apply
./scripts/deploy.sh dev-account1-us-west-2 apply

# Deploy all regions for Account 2
./scripts/deploy.sh dev-account2-us-east-1 apply
./scripts/deploy.sh dev-account2-us-west-2 apply
```

## 💰 Cost Optimization

### **All Deployments: $0.00**
- ✅ VPC (Free)
- ✅ Subnets (Free)
- ✅ Internet Gateway (Free)
- ✅ Route Tables (Free)
- ❌ NAT Gateway (Disabled)
- ❌ Elastic IPs (Disabled)

## 📚 Documentation

See `docs/` folder for detailed documentation:
- [State Management Best Practices](docs/state-management.md)
- [Multi-Account Setup Guide](docs/multi-account-setup.md)
- [CI/CD Pipeline Configuration](docs/cicd-setup.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

## 🛠️ Prerequisites

- AWS CLI configured with SSO profiles
- Terraform >= 1.0
- Active AWS SSO sessions:
  ```bash
  aws sso login --use-device-code --profile my-sso-profile
  aws sso login --use-device-code --profile account2-sso
  ```

## 🎯 Next Steps

1. **Test per-region deployment**: Start with single region
2. **Scale to parallel deployment**: Deploy multiple regions simultaneously
3. **Setup CI/CD**: Automate deployments via GitHub Actions
4. **Add monitoring**: Integrate CloudWatch and cost tracking
5. **Extend to more regions**: Add eu-west-1, ap-southeast-1, etc.
