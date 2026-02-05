#!/bin/bash

# Create S3 bucket and DynamoDB table for Terraform remote state
# Run this in Account 2

ACCOUNT_ID="509507123602"
REGION="us-east-1"
BUCKET_NAME="terraform-state-vpc-${ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-locks-vpc"

echo "Setting up remote state backend for Account 2..."

# Create S3 bucket for state
aws s3 mb s3://${BUCKET_NAME} --region ${REGION} --profile account2-sso

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket ${BUCKET_NAME} \
  --versioning-configuration Status=Enabled \
  --profile account2-sso

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket ${BUCKET_NAME} \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }' \
  --profile account2-sso

# Block public access
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile account2-sso

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name ${DYNAMODB_TABLE} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ${REGION} \
  --profile account2-sso

echo "✅ Account 2 remote state backend created:"
echo "   S3 Bucket: ${BUCKET_NAME}"
echo "   DynamoDB Table: ${DYNAMODB_TABLE}"
