terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  shared_config_files      = ["/Users/juan/.aws/config"]
  shared_credentials_files = ["/Users/juan/.aws/credentials"]
  profile                  = "default"


  default_tags {
    tags = {
      owner       = "Juan Roldan"
      project     = "AWS EKS Cluster"
      cost-center = "AWS EKS Billing"
      Name        = "Managed by Terraform"
    }
  }
}
