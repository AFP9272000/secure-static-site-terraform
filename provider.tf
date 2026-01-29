terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

provider "aws" {
  # Primary region for the site. This can be overridden via a tfvars file.
  region = var.region
}

# The Web ACL and CloudFront distribution must be created in us‑east‑1. Use an alias
# provider here so that only the WAF uses this region.
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
data "aws_caller_identity" "current" {}