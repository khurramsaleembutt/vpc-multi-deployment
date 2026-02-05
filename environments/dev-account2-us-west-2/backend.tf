# Remote State Backend Configuration
terraform {
  backend "s3" {
    bucket         = "terraform-state-vpc-509507123602"
    key            = "vpc/dev-account2-us-west-2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-vpc"
    encrypt        = true
  }
}
