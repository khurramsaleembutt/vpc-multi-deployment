# EKS Troubleshooting Guide

## Pod Identity Issues

### Issue 1: Fluent Bit Pod Identity Authentication Failures

**Symptoms:**
- Fluent Bit pods showing authentication errors
- Logs showing IMDS timeout errors
- Error messages: `Failed to retrieve credentials for AWS Profile default`
- Logs: `[warn] [imds] failed to retrieve IMDSv2 token`

**Root Cause:**
Pod Identity timing issue - Fluent Bit pods were created **before** Pod Identity associations existed.

**Solution Steps:**

#### 1. Verify Pod Identity Setup
```bash
# Check Pod Identity addon status
aws eks describe-addon --cluster-name CLUSTER_NAME --addon-name eks-pod-identity-agent --profile PROFILE

# Check Pod Identity associations
aws eks list-pod-identity-associations --cluster-name CLUSTER_NAME --profile PROFILE
```

#### 2. Check Pod Identity Injection
```bash
# Verify pod has Pod Identity environment variables
kubectl describe pod POD_NAME -n NAMESPACE | grep -A 5 "AWS_CONTAINER"

# Expected output:
# AWS_CONTAINER_CREDENTIALS_FULL_URI: http://169.254.170.23/v1/credentials
# AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE: /var/run/secrets/pods.eks.amazonaws.com/serviceaccount/eks-pod-identity-token
```

#### 3. Test Pod Identity Credentials
```bash
# Test credentials endpoint from inside pod
kubectl exec POD_NAME -n NAMESPACE -- sh -c 'curl -H "Authorization: $(cat /var/run/secrets/pods.eks.amazonaws.com/serviceaccount/eks-pod-identity-token)" http://169.254.170.23/v1/credentials'

# Should return valid AWS credentials JSON
```

#### 4. Chart Version Fix
**Critical:** Fluent Bit chart version 0.1.35 has Pod Identity compatibility issues.

```bash
# Upgrade to version 0.2.0 (required for proper Pod Identity support)
# In Terraform configuration:
version = "0.2.0"  # Changed from "0.1.35"
```

#### 5. Force Pod Recreation
```bash
# If pods exist before associations, restart them
kubectl delete pod -l app.kubernetes.io/name=aws-for-fluent-bit -n amazon-cloudwatch
```

**Prevention:**
Ensure Terraform `depends_on` includes Pod Identity associations:
```hcl
depends_on = [
  aws_eks_pod_identity_association.fluent_bit,
  # other dependencies
]
```

---

## CloudWatch Logging Issues

### Issue 2: Missing System Pod Logs (aws-node, coredns)

**Symptoms:**
- Only 3 out of 6 pods appear in CloudWatch log streams
- Missing logs for: `aws-node`, `coredns`
- Present logs for: `kube-proxy`, `eks-pod-identity-agent`, `fluent-bit`

**Investigation Steps:**

#### 1. Verify Log Files Exist
```bash
# Check log files on node via Fluent Bit pod
kubectl exec FLUENT_BIT_POD -n amazon-cloudwatch -- ls -la /var/log/containers/ | grep -E "(aws-node|coredns)"

# Check log file content
kubectl exec FLUENT_BIT_POD -n amazon-cloudwatch -- tail -5 /var/log/containers/aws-node-*.log
kubectl exec FLUENT_BIT_POD -n amazon-cloudwatch -- tail -5 /var/log/containers/coredns-*.log
```

#### 2. Check Fluent Bit Detection
```bash
# Verify Fluent Bit detects the log files
kubectl logs FLUENT_BIT_POD -n amazon-cloudwatch | grep -E "(aws-node|coredns)" | grep "inotify_fs_add"

# Should show file detection messages
```

#### 3. Check Exclusion Settings
```bash
# Check current exclusion configuration
kubectl get configmap aws-for-fluent-bit -n amazon-cloudwatch -o yaml | grep -A 5 -B 5 "K8S-Logging.Exclude"

# Check for pod annotations that might exclude logging
kubectl describe pod -n kube-system POD_NAME | grep -i "fluentbit\|logging"
```

#### 4. Attempted Solutions (Unsuccessful)

**Tried: Disabling K8S-Logging.Exclude**
```hcl
# In Terraform Helm values
filter = {
  k8sLoggingExclude = "Off"  # Changed from "On"
}
```
**Result:** Did not resolve the issue - aws-node and coredns still excluded

**Current Status:** 
- ✅ Log files exist and have content
- ✅ Fluent Bit detects the files  
- ✅ No explicit exclusion annotations found
- ❌ Logs still not processed to CloudWatch

**Hypothesis:**
- EKS may have **hardcoded exclusions** for certain system pods
- **Built-in filtering** in Fluent Bit for aws-node and coredns
- **Different log processing pipeline** for these specific pods

#### 5. Alternative Investigation Methods

**Check Fluent Bit Processing:**
```bash
# Look for processing errors
kubectl logs FLUENT_BIT_POD -n amazon-cloudwatch | grep -E "(aws-node|coredns)" | grep -v "inotify_fs_add"

# Check if logs are being matched by rewrite rules
kubectl logs FLUENT_BIT_POD -n amazon-cloudwatch | grep -E "Creating.*aws-node|Creating.*coredns"
```

**Verify Log Stream Creation:**
```bash
# List all log streams in application log group
aws logs describe-log-streams --log-group-name "/aws/eks/ENVIRONMENT/ecommerce/applications" --profile PROFILE
```

---

## General Troubleshooting Commands

### Pod Identity Debugging
```bash
# Test Pod Identity with simple application
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-identity-test
  namespace: amazon-cloudwatch
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pod-identity-test
  namespace: amazon-cloudwatch
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pod-identity-test
  template:
    metadata:
      labels:
        app: pod-identity-test
    spec:
      serviceAccountName: pod-identity-test
      containers:
      - name: aws-cli
        image: amazon/aws-cli:latest
        command: ["sleep", "3600"]
        env:
        - name: AWS_DEFAULT_REGION
          value: us-east-1
EOF

# Create Pod Identity association for test
aws eks create-pod-identity-association \
  --cluster-name CLUSTER_NAME \
  --namespace amazon-cloudwatch \
  --service-account pod-identity-test \
  --role-arn ROLE_ARN \
  --profile PROFILE

# Test credentials
kubectl exec POD_NAME -n amazon-cloudwatch -- aws sts get-caller-identity
```

### Fluent Bit Configuration Debugging
```bash
# View complete Fluent Bit configuration
kubectl get configmap aws-for-fluent-bit -n amazon-cloudwatch -o yaml

# Check Fluent Bit pod logs for errors
kubectl logs -f FLUENT_BIT_POD -n amazon-cloudwatch

# Verify CloudWatch log groups exist
aws logs describe-log-groups --profile PROFILE | grep ecommerce
```

### Infrastructure State Debugging
```bash
# Check Terraform state for Pod Identity resources
terraform state list | grep pod_identity

# Verify EKS access entries
aws eks list-access-entries --cluster-name CLUSTER_NAME --profile PROFILE

# Check service account annotations
kubectl describe serviceaccount fluent-bit -n amazon-cloudwatch
```

---

## Key Lessons Learned

1. **Pod Identity Timing**: Pods must be created **after** Pod Identity associations exist
2. **Chart Version Compatibility**: Fluent Bit 0.1.35 has Pod Identity bugs - use 0.2.0+
3. **System Pod Exclusions**: Some EKS system pods may have built-in logging exclusions
4. **Terraform Dependencies**: Always include proper `depends_on` for Pod Identity resources
5. **Pod Recreation Required**: Existing pods don't get Pod Identity injection retroactively

---

## Status Summary

| Issue | Status | Solution |
|-------|--------|----------|
| Fluent Bit Pod Identity Authentication | ✅ **RESOLVED** | Upgrade to chart version 0.2.0 + pod restart |
| Missing aws-node logs in CloudWatch | ❌ **PENDING** | Under investigation - likely EKS built-in exclusion |
| Missing coredns logs in CloudWatch | ❌ **PENDING** | Under investigation - likely EKS built-in exclusion |
| Other system pods logging | ✅ **WORKING** | kube-proxy, eks-pod-identity-agent logs flowing |

---

## Next Steps for Pending Issues

1. **Research EKS Documentation**: Check if aws-node and coredns have special logging configurations
2. **Custom Log Groups**: Consider creating dedicated log groups for system pods
3. **Alternative Logging**: Evaluate if these system pod logs are needed for monitoring
4. **AWS Support**: Contact AWS support for clarification on system pod logging behavior
