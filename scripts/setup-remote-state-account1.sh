#!/bin/bash

# Create S3 bucket and DynamoDB table for Terraform remote state
# Run this in Account 1 first

ACCOUNT_ID="093285711854"
REGION="us-east-1"
BUCKET_NAME="terraform-state-vpc-${ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-locks-vpc"

echo "Setting up remote state backend for Account 1..."

# Create S3 bucket for state
aws s3 mb s3://${BUCKET_NAME} --region ${REGION} --profile my-sso-profile

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket ${BUCKET_NAME} \
  --versioning-configuration Status=Enabled \
  --profile my-sso-profile

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
  --profile my-sso-profile

# Block public access
aws s3api put-public-access-block \
  --bucket ${BUCKET_NAME} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --profile my-sso-profile

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name ${DYNAMODB_TABLE} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10 \
  --region ${REGION} \
  --profile my-sso-profile

echo "✅ Account 1 remote state backend created:"
echo "   S3 Bucket: ${BUCKET_NAME}"
echo "   DynamoDB Table: ${DYNAMODB_TABLE}"
