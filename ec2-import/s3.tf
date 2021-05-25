provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "examplebucket" {
  bucket = "anand0987uio"
  acl    = "private"

  versioning {
    enabled = true
  }
}