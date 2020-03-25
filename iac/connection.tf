provider "aws" {
  region = "us-east-1"
}

# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = "xpresso-terraform"
    key    = "microservice_template/terraform.tfstate"
    region = "us-east-1"
  }
}