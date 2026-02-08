#!/bin/bash

# Create GitHub Actions OIDC Role for Account 1 (093285711854)
# Run this in Account 1 with your GitHub username

GITHUB_USERNAME="khurramsaleembutt"
REPO_NAME="vpc-multi-deployment"
ACCOUNT_ID="093285711854"

echo "Creating GitHub Actions OIDC Role for Account 1..."

# Create trust policy
cat > trust-policy-account1.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USERNAME}/${REPO_NAME}:ref:refs/heads/main",
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

# Create permissions policy
cat > permissions-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "sts:GetCallerIdentity"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-vpc-${ACCOUNT_ID}",
        "arn:aws:s3:::terraform-state-vpc-${ACCOUNT_ID}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:${ACCOUNT_ID}:table/terraform-locks-vpc"
    }
  ]
}
EOF

# Create OIDC provider (if not exists)
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --client-id-list sts.amazonaws.com \
  --profile my-sso-profile || echo "OIDC provider already exists"

# Create IAM role
aws iam create-role \
  --role-name GitHubActionsVPCRole \
  --assume-role-policy-document file://trust-policy-account1.json \
  --profile my-sso-profile

# Attach permissions policy
aws iam put-role-policy \
  --role-name GitHubActionsVPCRole \
  --policy-name VPCDeploymentPolicy \
  --policy-document file://permissions-policy.json \
  --profile my-sso-profile

echo "✅ Account 1 Role ARN: arn:aws:iam::${ACCOUNT_ID}:role/GitHubActionsVPCRole"
