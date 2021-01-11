provider "aws" {
  region = var.AWS_REGION
}
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-storage-s3-vpc"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
