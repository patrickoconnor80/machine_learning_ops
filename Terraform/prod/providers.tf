terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
  }
  backend "s3" {
    bucket  = "terraform-state-harry-prod"
    key     = "prod.tfstate"
    encrypt = "true"
    profile = "data_engineering_sandbox"
    region  = "us-east-1"
  }
}

provider "aws" {
  profile             = "data_engineering_sandbox"
  allowed_account_ids = ["948065143262"]
  region              = "us-east-1"
  default_tags {
    tags = {
      Environment = "prod"
      Owner       = "data-engineering"
      Terraform   = "true"
    }
  }
}

resource "aws_s3_bucket" "terraform" {
  bucket = "terraform-state-harry-${var.env_name}"
}