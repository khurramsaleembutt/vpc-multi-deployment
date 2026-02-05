#!/bin/bash

# Multi-Region VPC Deployment Script
# Usage: ./deploy.sh [environment] [action]

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🏗️  Multi-Region VPC Deployment"
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"
echo "=================================="

# Check if environment exists
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"
if [ ! -d "$ENV_DIR" ]; then
    echo "❌ Environment '$ENVIRONMENT' not found in $ENV_DIR"
    exit 1
fi

cd "$ENV_DIR"

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
if ! aws sts get-caller-identity --profile my-sso-profile &> /dev/null; then
    echo "❌ AWS SSO session expired. Please run: aws sso login --profile my-sso-profile"
    exit 1
fi

# Initialize Terraform
echo "🚀 Initializing Terraform..."
terraform init

case $ACTION in
    "plan")
        echo "📋 Planning deployment..."
        terraform plan -var-file="terraform.tfvars"
        ;;
    "apply")
        echo "🚀 Applying deployment..."
        terraform apply -var-file="terraform.tfvars" -auto-approve
        echo "✅ Deployment completed!"
        echo ""
        echo "📊 Deployment Summary:"
        terraform output deployment_summary
        ;;
    "destroy")
        echo "💥 Destroying infrastructure..."
        terraform destroy -var-file="terraform.tfvars" -auto-approve
        echo "✅ Infrastructure destroyed!"
        ;;
    "output")
        echo "📊 Showing outputs..."
        terraform output
        ;;
    *)
        echo "❌ Invalid action. Use: plan, apply, destroy, or output"
        exit 1
        ;;
esac
