terraform {
 backend “s3” {
 bucket = "terraform-remote-state-storage-s3-vpc"
 region = "us-east-1"
 key = "vpc"
 }
}