# Specify the required Terraform version
terraform {
  required_version = ">= 0.12"
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}
