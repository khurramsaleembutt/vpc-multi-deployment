# Remote State Backend Configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-vpc-093285711854"
    key            = "vpc/prod-account1-us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-vpc"
    encrypt        = true
  }
}
