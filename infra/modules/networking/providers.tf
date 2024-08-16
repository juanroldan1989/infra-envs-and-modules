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

  default_tags {
    tags = {
      owner       = "Fastned"
      project     = "AWS EKS Cluster"
      cost-center = "AWS EKS Billing"
      Name        = "Managed by Terraform"
    }
  }
}
