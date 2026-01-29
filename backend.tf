terraform {
  backend "s3" {
    bucket         = "static-terraform-state-bucket"
    key            = "secure-static-site/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "static-terraform-state-lock"
  }
}