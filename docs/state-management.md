# State Management Best Practices

## Overview

This document explains the state management strategies used in this project and why separate state files per region is the recommended approach.

## State Management Strategies

### 1. Single State, Multi-Region (Legacy)

```
environments/dev/
├── main.tf (deploys to us-east-1 AND us-west-2)
└── terraform.tfstate (single state file)
```

**Pros:**
- ✅ Atomic deployments (both regions succeed/fail together)
- ✅ Simpler management (one state file)
- ✅ Cross-region dependencies possible

**Cons:**
- ❌ Region failure affects entire deployment
- ❌ Slower deployments (sequential region processing)
- ❌ Cannot deploy regions independently

### 2. Separate State Per Region (Recommended)

```
environments/
├── dev-account1-us-east-1/
│   ├── main.tf (single region)
│   └── terraform.tfstate
└── dev-account1-us-west-2/
    ├── main.tf (single region)
    └── terraform.tfstate
```

**Pros:**
- ✅ **Independent deployments** (deploy regions separately)
- ✅ **Fault isolation** (one region failure doesn't affect others)
- ✅ **Parallel deployments** (faster CI/CD)
- ✅ **Granular control** (different configurations per region)
- ✅ **Easier rollbacks** (rollback single region)

**Cons:**
- ❌ More state files to manage
- ❌ Cross-region dependencies require data sources

## Implementation Examples

### Independent Region Deployment
```bash
# Deploy only us-east-1
./scripts/deploy.sh dev-account1-us-east-1 apply

# Deploy only us-west-2 (independent of us-east-1)
./scripts/deploy.sh dev-account1-us-west-2 apply
```

### Parallel Deployment
```bash
# Deploy all regions simultaneously
./scripts/deploy.sh dev-account1-us-east-1 apply &
./scripts/deploy.sh dev-account1-us-west-2 apply &
./scripts/deploy.sh dev-account2-us-east-1 apply &
./scripts/deploy.sh dev-account2-us-west-2 apply &
wait
```

## Best Practices

1. **Use separate state files for production environments**
2. **Keep related resources in the same state file**
3. **Use remote state backends (S3 + DynamoDB) for team collaboration**
4. **Implement state locking to prevent concurrent modifications**
5. **Regular state backups and versioning**

## Remote State Configuration (Future Enhancement)

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "vpc/dev-account1-us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```
